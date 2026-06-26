import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pulse_chat/core/network/api_config.dart';
import 'package:pulse_chat/features/chats/data/chat_message_model.dart';
import 'package:tostore/tostore.dart';

enum RealtimeConnectionStatus { disconnected, connecting, connected }

class RealtimeEvent {
  const RealtimeEvent({required this.name, required this.payload});

  final String name;
  final Map<String, dynamic> payload;
}

@lazySingleton
class ChatRealtimeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StreamController<RealtimeEvent> _eventsController = StreamController<RealtimeEvent>.broadcast();
  final StreamController<RealtimeConnectionStatus> _statusController = StreamController<RealtimeConnectionStatus>.broadcast();
  final Map<String, List<ChatMessage>> _messagesByChat = {};
  final Map<String, StreamController<List<ChatMessage>>> _messageControllers = {};
  final Map<String, bool> _presenceByUser = {};

  final Future<ToStore> _db = _openMessagesDatabase();

  static Future<ToStore> _openMessagesDatabase() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    return ToStore.open(dbPath: appDirectory.path, dbName: 'pulse_chat_messages');
  }

  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  var _manuallyDisconnected = false;
  RealtimeConnectionStatus _status = RealtimeConnectionStatus.disconnected;

  Stream<RealtimeEvent> get events => _eventsController.stream;
  Stream<RealtimeConnectionStatus> get statusStream => _statusController.stream;
  RealtimeConnectionStatus get status => _status;

  bool isOnline(String uid) => _presenceByUser[uid] ?? false;

  Stream<List<ChatMessage>> messagesFor(String chatId) {
    return _controllerFor(chatId).stream;
  }

  List<ChatMessage> currentMessagesFor(String chatId) {
    return List.unmodifiable(_messagesByChat[chatId] ?? const []);
  }

  Future<void> connect() async {
    if (_status == RealtimeConnectionStatus.connecting || _status == RealtimeConnectionStatus.connected) {
      return;
    }

    final user = _auth.currentUser;
    if (user == null) return;

    _manuallyDisconnected = false;
    _setStatus(RealtimeConnectionStatus.connecting);

    try {
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        _setStatus(RealtimeConnectionStatus.disconnected);
        return;
      }

      final uri = Uri.parse(ApiConfig.wsUrl).replace(queryParameters: {'token': token});
      final socket = await WebSocket.connect(uri.toString());
      _socket = socket;
      _setStatus(RealtimeConnectionStatus.connected);
      _startHeartbeat();

      await _socketSubscription?.cancel();
      _socketSubscription = socket.listen(
        _handleRawMessage,
        onDone: _handleSocketClosed,
        onError: (_) => _handleSocketClosed(),
        cancelOnError: true,
      );
    } on Exception {
      _setStatus(RealtimeConnectionStatus.disconnected);
      _scheduleReconnect();
    }
  }

  Future<void> disconnect() async {
    _manuallyDisconnected = true;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    await _socketSubscription?.cancel();
    await _socket?.close();
    _socket = null;
    _setStatus(RealtimeConnectionStatus.disconnected);
  }

  void sendMessage({
    required String chatId,
    required String receiverId,
    required String content,
    ChatMessage? replyTo,
  }) {
    final messageId = DateTime.now().microsecondsSinceEpoch.toString();
    final message = ChatMessage(
      id: messageId,
      text: content,
      isMine: true,
      time: _formatTime(DateTime.now()),
      status: MessageStatus.sending,
      replyTo: replyTo,
    );
    _upsertMessage(chatId, message);

    final localPayload = <String, dynamic>{
      'messageId': messageId,
      'chatId': chatId,
      'senderId': _auth.currentUser?.uid,
      'receiverId': receiverId,
      'content': content,
    };
    if (replyTo != null) {
      localPayload['quotedMessageId'] = replyTo.id;
      localPayload['quotedMessage'] = {
        'messageId': replyTo.id,
        'chatId': chatId,
        'senderId': replyTo.isMine ? _auth.currentUser?.uid : receiverId,
        'content': replyTo.text,
        'messageType': 'text',
        'createdAt': DateTime.now().toIso8601String(),
      };
    }

    _eventsController.add(
      RealtimeEvent(
        name: 'local_message',
        payload: localPayload,
      ),
    );

    final wsPayload = <String, dynamic>{
      'messageId': messageId,
      'chatId': chatId,
      'receiverId': receiverId,
      'content': content,
      'messageType': 'text',
      'quotedMessageId': replyTo?.id,
    };
    if (replyTo != null) {
      wsPayload['quotedMessage'] = {
        'messageId': replyTo.id,
        'chatId': chatId,
        'senderId': replyTo.isMine ? _auth.currentUser?.uid : receiverId,
        'content': replyTo.text,
        'messageType': 'text',
        'createdAt': DateTime.now().toIso8601String(),
      };
    }

    _send('message', wsPayload);
  }

  void sendTyping({
    required String chatId,
    required String receiverId,
    required bool isTyping,
  }) {
    _send('typing', {
      'chatId': chatId,
      'receiverId': receiverId,
      'status': isTyping ? 'typing_start' : 'typing_stop',
    });
  }

  void sendMessageDelivered(String messageId) {
    _send('message_delivered', {'messageId': messageId});
  }

  void sendMessageSeen({
    required String messageId,
    required String chatId,
    required String senderId,
  }) {
    _send('message_seen', {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
    });
  }

  void _handleRawMessage(dynamic raw) {
    if (raw is! String) return;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return;

    final event = decoded['event'] as String?;
    final payload = decoded['payload'] is Map<String, dynamic> ? decoded['payload'] as Map<String, dynamic> : <String, dynamic>{};
    if (event == null) return;

    switch (event) {
      case 'contacts_presence':
        _handleContactsPresence(payload);
      case 'presence':
        _handlePresence(payload);
      case 'message':
        _handleIncomingMessage(payload);
      case 'message_ack':
        _updateMessageStatus(payload, MessageStatus.sent);
      case 'message_delivered':
        _updateMessageStatus(payload, MessageStatus.delivered);
      case 'message_seen':
        _updateMessageStatus(payload, MessageStatus.read);
    }

    _eventsController.add(RealtimeEvent(name: event, payload: payload));
  }

  void _handleContactsPresence(Map<String, dynamic> payload) {
    final onlineContacts = payload['onlineContacts'];
    if (onlineContacts is! Map<String, dynamic>) return;

    for (final entry in onlineContacts.entries) {
      _presenceByUser[entry.key] = entry.value == 'online';
    }
  }

  void _handlePresence(Map<String, dynamic> payload) {
    final userId = payload['userId'] as String?;
    final status = payload['status'] as String?;
    if (userId == null || status == null) return;

    _presenceByUser[userId] = status == 'online';
  }

  void _handleIncomingMessage(Map<String, dynamic> payload) {
    final messageId = payload['messageId'] as String?;
    final chatId = payload['chatId'] as String?;
    final content = payload['content'] as String?;
    final senderId = payload['senderId'] as String?;
    if (messageId == null || chatId == null || content == null) return;

    ChatMessage? replyTo;
    final quotedMsgJson = payload['quotedMessage'] as Map?;
    final quotedMsgId = payload['quotedMessageId'] as String?;
    if (quotedMsgJson != null) {
      final qId = quotedMsgJson['messageId'] as String? ?? quotedMsgId ?? '';
      final qContent = quotedMsgJson['content'] as String? ?? '';
      final qSenderId = quotedMsgJson['senderId'] as String?;
      final qIsMine = qSenderId == _auth.currentUser?.uid;
      final qCreatedAt = DateTime.tryParse(quotedMsgJson['createdAt'] as String? ?? '') ?? DateTime.now();
      replyTo = ChatMessage(
        id: qId,
        text: qContent,
        isMine: qIsMine,
        time: _formatTime(qCreatedAt),
      );
    } else if (quotedMsgId != null) {
      ChatMessage? existing;
      final list = _messagesByChat[chatId];
      if (list != null) {
        for (final m in list) {
          if (m.id == quotedMsgId) {
            existing = m;
            break;
          }
        }
      }
      if (existing != null) {
        replyTo = existing;
      } else {
        replyTo = ChatMessage(
          id: quotedMsgId,
          text: '',
          isMine: false,
          time: '',
        );
      }
    }

    final createdAt = DateTime.tryParse(payload['createdAt'] as String? ?? '') ?? DateTime.now();
    _upsertMessage(
      chatId,
      ChatMessage(
        id: messageId,
        text: content,
        isMine: senderId == _auth.currentUser?.uid,
        time: _formatTime(createdAt),
        status: MessageStatus.delivered,
        replyTo: replyTo,
      ),
    );

    if (senderId != null && senderId != _auth.currentUser?.uid) {
      sendMessageDelivered(messageId);
    }
  }

  void _updateMessageStatus(Map<String, dynamic> payload, MessageStatus status) {
    final messageId = payload['messageId'] as String?;
    final chatId = payload['chatId'] as String?;
    if (messageId == null || chatId == null) return;

    final messages = _messagesByChat[chatId];
    if (messages == null) return;

    final index = messages.indexWhere((message) => message.id == messageId);
    if (index == -1) return;

    final old = messages[index];
    messages[index] = ChatMessage(
      id: old.id,
      text: old.text,
      isMine: old.isMine,
      time: old.time,
      status: status,
      replyTo: old.replyTo,
      reactions: old.reactions,
      urlPreview: old.urlPreview,
      isDeleted: old.isDeleted,
    );
    _emitMessages(chatId);
    unawaited(_saveMessagesToDb(chatId));
  }

  void _upsertMessage(String chatId, ChatMessage message) {
    final messages = _messagesByChat.putIfAbsent(chatId, () => []);
    final index = messages.indexWhere((existing) => existing.id == message.id);
    if (index == -1) {
      messages.add(message);
    } else {
      messages[index] = message;
    }
    _emitMessages(chatId);
    unawaited(_saveMessagesToDb(chatId));
  }

  void _send(String event, Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket == null || _status != RealtimeConnectionStatus.connected) {
      _scheduleReconnect();
      return;
    }

    socket.add(
      jsonEncode({
        'event': event,
        'payload': payload,
      }),
    );
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      _send('ping', {});
    });
  }

  void _handleSocketClosed() {
    _heartbeatTimer?.cancel();
    _socket = null;
    _setStatus(RealtimeConnectionStatus.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_manuallyDisconnected || _reconnectTimer?.isActive == true) return;
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      unawaited(connect());
    });
  }

  void _setStatus(RealtimeConnectionStatus status) {
    if (_status == status) return;
    _status = status;
    _statusController.add(status);
  }

  StreamController<List<ChatMessage>> _controllerFor(String chatId) {
    return _messageControllers.putIfAbsent(
      chatId,
      () => StreamController<List<ChatMessage>>.broadcast(
        onListen: () {
          if (!_messagesByChat.containsKey(chatId)) {
            unawaited(_loadAndEmitMessages(chatId));
          } else {
            _emitMessages(chatId);
          }
        },
      ),
    );
  }

  Future<void> _loadAndEmitMessages(String chatId) async {
    final localMsgs = await _loadMessagesFromDb(chatId);
    if (!_messagesByChat.containsKey(chatId)) {
      _messagesByChat[chatId] = localMsgs;
    } else {
      final existing = _messagesByChat[chatId]!;
      for (final msg in localMsgs) {
        if (!existing.any((m) => m.id == msg.id)) {
          existing.add(msg);
        }
      }
    }
    _emitMessages(chatId);
  }

  void _emitMessages(String chatId) {
    final controller = _messageControllers[chatId];
    if (controller == null || controller.isClosed) return;
    controller.add(List.unmodifiable(_messagesByChat[chatId] ?? const []));
  }

  String _formatTime(DateTime dateTime) {
    final h = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final m = dateTime.minute.toString().padLeft(2, '0');
    final ampm = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  Map<String, dynamic> _messageToJson(ChatMessage message) {
    return {
      'id': message.id,
      'text': message.text,
      'isMine': message.isMine,
      'time': message.time,
      'status': message.status.name,
      'replyTo': message.replyTo != null ? _messageToJson(message.replyTo!) : null,
      'reactions': message.reactions.map((key, value) => MapEntry(key, List<String>.from(value))),
      'urlPreview': message.urlPreview != null ? {
        'url': message.urlPreview!.url,
        'title': message.urlPreview!.title,
        'description': message.urlPreview!.description,
        'siteName': message.urlPreview!.siteName,
        'imageUrl': message.urlPreview!.imageUrl,
      } : null,
      'isDeleted': message.isDeleted,
    };
  }

  ChatMessage _messageFromJson(Map<String, dynamic> json) {
    final reactionsJson = json['reactions'] as Map?;
    final reactions = <String, List<String>>{};
    if (reactionsJson != null) {
      reactionsJson.forEach((key, value) {
        if (value is List) {
          reactions[key.toString()] = List<String>.from(value);
        }
      });
    }

    UrlPreviewData? urlPreview;
    final previewJson = json['urlPreview'] as Map?;
    if (previewJson != null) {
      urlPreview = UrlPreviewData(
        url: previewJson['url'] as String? ?? '',
        title: previewJson['title'] as String? ?? '',
        description: previewJson['description'] as String? ?? '',
        siteName: previewJson['siteName'] as String? ?? '',
        imageUrl: previewJson['imageUrl'] as String?,
      );
    }

    return ChatMessage(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      isMine: json['isMine'] as bool? ?? false,
      time: json['time'] as String? ?? '',
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.read,
      ),
      replyTo: json['replyTo'] != null ? _messageFromJson(Map<String, dynamic>.from(json['replyTo'] as Map)) : null,
      reactions: reactions,
      urlPreview: urlPreview,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Future<void> _saveMessagesToDb(String chatId) async {
    final messages = _messagesByChat[chatId];
    if (messages == null) return;
    try {
      final db = await _db;
      final listJson = messages.map(_messageToJson).toList();
      await db.setValue('messages_$chatId', listJson);
    } on Object catch (_) {}
  }

  Future<List<ChatMessage>> _loadMessagesFromDb(String chatId) async {
    try {
      final db = await _db;
      final data = await db.getValue('messages_$chatId');
      if (data is List) {
        final messages = data.map((json) {
          return _messageFromJson(Map<String, dynamic>.from(json as Map));
        }).toList();
        return messages;
      }
    } on Object catch (_) {}
    return [];
  }
}


