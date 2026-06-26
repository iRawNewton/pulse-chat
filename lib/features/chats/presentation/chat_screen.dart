import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_chat/config/routes/app_routes.dart';
import 'package:pulse_chat/core/di/injection.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/chats/data/chat_message_model.dart';
import 'package:pulse_chat/features/chats/data/chat_realtime_service.dart';
import 'package:pulse_chat/features/chats/widgets/date_chip.dart';
import 'package:pulse_chat/features/chats/widgets/message_option_sheet.dart';
import 'package:pulse_chat/features/chats/widgets/mic_button.dart';
import 'package:pulse_chat/features/chats/widgets/mini_avatar.dart';
import 'package:pulse_chat/features/chats/widgets/send_button.dart';
import 'package:pulse_chat/features/chats/widgets/swipeable_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.contactName = 'Aanya Sharma',
    this.contactId,
    this.chatId,
    this.isOnline = true,
    this.isGroup = false,
  });

  final String contactName;
  final String? contactId;
  final String? chatId;
  final bool isOnline;
  final bool isGroup;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatRealtimeService _realtimeService;
  late final String _chatId;
  late final String? _receiverId;
  List<ChatMessage> _messages = const [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  ChatMessage? _replyingTo;
  bool _showScrollDown = false;
  bool _isTyping = false;
  bool _remoteTyping = false;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  StreamSubscription<RealtimeEvent>? _eventsSubscription;

  // Map messageId → GlobalKey so we can scroll to it
  final Map<String, GlobalKey> _messageKeys = {};

  int _messagesLimit = 20;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<ChatMessage> get _visibleMessages {
    if (_messages.length <= _messagesLimit) {
      return _messages;
    }
    return _messages.sublist(_messages.length - _messagesLimit);
  }

  List<ChatMessage> get _filteredMessages {
    if (!_isSearching || _searchQuery.isEmpty) {
      return _visibleMessages;
    }
    return _messages.where((msg) => msg.text.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  void initState() {
    super.initState();
    _realtimeService = getIt<ChatRealtimeService>();
    _receiverId = widget.contactId;
    _chatId = widget.chatId ?? widget.contactId ?? widget.contactName;
    _messages = _realtimeService.currentMessagesFor(_chatId);
    _syncMessageKeys(_messages);
    _messagesSubscription = _realtimeService.messagesFor(_chatId).listen((messages) {
      if (!mounted) return;
      final oldLength = _messages.length;
      setState(() {
        _messages = messages;
        _syncMessageKeys(messages);
        if (messages.length > oldLength && oldLength > 0) {
          _messagesLimit += messages.length - oldLength;
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animated: true));
    });
    _eventsSubscription = _realtimeService.events.listen(_handleRealtimeEvent);
    unawaited(_realtimeService.connect());
    _inputController.addListener(() {
      final t = _inputController.text.trim().isNotEmpty;
      if (t != _isTyping) {
        setState(() => _isTyping = t);
        _sendTyping(t);
      }
    });
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.trim();
        });
      }
    });
    _inputFocus.addListener(() {
      if (mounted) setState(() {});
    });
    _scrollController.addListener(() {
      _updateScrollDownVisibility();

      // Scroll Pagination
      if (_scrollController.hasClients && _scrollController.offset <= 100 && _messagesLimit < _messages.length && !_isSearching) {
        final oldExtent = _scrollController.position.maxScrollExtent;
        final oldOffset = _scrollController.offset;
        setState(() {
          _messagesLimit = (_messagesLimit + 20).clamp(20, _messages.length);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients) return;
          final newExtent = _scrollController.position.maxScrollExtent;
          final diff = newExtent - oldExtent;
          if (diff > 0) {
            _scrollController.jumpTo(oldOffset + diff);
          }
          _updateScrollDownVisibility();
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _sendTyping(false);
    if (_messagesSubscription != null) {
      unawaited(_messagesSubscription!.cancel());
    }
    if (_eventsSubscription != null) {
      unawaited(_eventsSubscription!.cancel());
    }
    _inputController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _syncMessageKeys(List<ChatMessage> messages) {
    for (final message in messages) {
      _messageKeys.putIfAbsent(message.id, GlobalKey.new);
    }
  }

  void _handleRealtimeEvent(RealtimeEvent event) {
    if (!mounted) return;
    if (event.name == 'typing' && event.payload['chatId'] == _chatId) {
      final status = event.payload['status'] as String?;
      setState(() => _remoteTyping = status == 'typing_start');
    }

    if (event.name == 'message' && event.payload['chatId'] == _chatId) {
      final senderId = event.payload['senderId'] as String?;
      final messageId = event.payload['messageId'] as String?;
      if (senderId != null && messageId != null && senderId == _receiverId) {
        _realtimeService.sendMessageSeen(
          messageId: messageId,
          chatId: _chatId,
          senderId: senderId,
        );
      }
    }
  }

  Future<void> _scrollToBottom({bool animated = false}) async {
    if (!_scrollController.hasClients) return;
    if (animated) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
    if (mounted && _showScrollDown) {
      setState(() => _showScrollDown = false);
    }
  }

  void _updateScrollDownVisibility() {
    if (!_scrollController.hasClients) return;

    final show = !_isSearching && _scrollController.position.extentAfter > 120;
    if (show != _showScrollDown && mounted) {
      setState(() => _showScrollDown = show);
    }
  }

  Future<void> _scrollToMessage(String id) async {
    final key = _messageKeys[id];
    if (key?.currentContext == null) return;
    await Scrollable.ensureVisible(
      key!.currentContext!,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.3,
    );
    // Flash highlight
    setState(() => _highlightedId = id);
    Future.delayed(const Duration(milliseconds: 1200), () => setState(() => _highlightedId = null));
  }

  String? _highlightedId;

  void _onQuoteTap(String quotedId) {
    final index = _messages.indexWhere((m) => m.id == quotedId);
    if (index != -1) {
      final requiredLimit = _messages.length - index;
      if (_messagesLimit < requiredLimit) {
        setState(() {
          _messagesLimit = requiredLimit;
        });
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_scrollToMessage(quotedId));
      });
    }
  }

  void _onSearchResultTap(ChatMessage msg) {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchQuery = '';

      final index = _messages.indexOf(msg);
      if (index != -1) {
        final requiredLimit = _messages.length - index;
        if (_messagesLimit < requiredLimit) {
          _messagesLimit = requiredLimit;
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_scrollToMessage(msg.id));
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    final receiverId = _receiverId;
    if (receiverId == null || receiverId.isEmpty) return;

    _realtimeService.sendMessage(
      chatId: _chatId,
      receiverId: receiverId,
      content: text,
      replyTo: _replyingTo,
    );
    setState(() => _replyingTo = null);
    _inputController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animated: true));
  }

  void _sendTyping(bool isTyping) {
    final receiverId = _receiverId;
    if (receiverId == null || receiverId.isEmpty) return;
    _realtimeService.sendTyping(
      chatId: _chatId,
      receiverId: receiverId,
      isTyping: isTyping,
    );
  }

  void _addReaction(ChatMessage msg, String emoji) {
    setState(() {
      final reactions = Map<String, List<String>>.from(msg.reactions);
      final users = List<String>.from(reactions[emoji] ?? []);
      if (users.contains('me')) {
        users.remove('me');
        if (users.isEmpty) {
          reactions.remove(emoji);
        } else {
          reactions[emoji] = users;
        }
      } else {
        users.add('me');
        reactions[emoji] = users;
      }
      msg.reactions = reactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: _buildAppBar(colors),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildMessageList(colors),
                  if (_showScrollDown) _buildScrollDownButton(colors),
                ],
              ),
            ),
            if (_replyingTo != null) _buildReplyBanner(colors),
            _buildInputBar(colors),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────

  PreferredSizeWidget _buildAppBar(AppColors colors) {
    if (_isSearching) {
      return AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary, size: 22.sp),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
              _searchQuery = '';
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: AppTextStyles.w500.copyWith(fontSize: 16.sp, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search messages...',
            hintStyle: AppTextStyles.w400.copyWith(fontSize: 15.sp, color: colors.textTertiary),
            border: InputBorder.none,
            filled: true,
            fillColor: colors.background,
          ),
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close_rounded, color: colors.textPrimary, size: 20.sp),
              onPressed: _searchController.clear,
            ),
          SizedBox(width: 8.w),
        ],
      );
    }

    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 18.sp),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.home);
          }
        },
      ),
      title: Row(
        children: [
          MiniAvatar(name: widget.contactName, colors: colors),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contactName,
                  style: AppTextStyles.w600.copyWith(fontSize: 16.sp, color: colors.textPrimary),
                ),
                Text(
                  _remoteTyping ? 'Typing...' : (widget.isOnline ? 'Online' : 'Last seen recently'),
                  style: AppTextStyles.w400.copyWith(
                    fontSize: 12.sp,
                    color: _remoteTyping || widget.isOnline ? colors.success : colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search_rounded, color: colors.textPrimary, size: 22.sp),
          onPressed: () => setState(() => _isSearching = true),
        ),
        IconButton(
          icon: Icon(Icons.videocam_outlined, color: colors.textPrimary, size: 22.sp),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.call_outlined, color: colors.textPrimary, size: 20.sp),
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: colors.textPrimary, size: 22.sp),
          color: colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          elevation: 8,
          onSelected: (value) {
            if (value == 'Search') {
              setState(() => _isSearching = true);
            }
          },
          itemBuilder: (_) => [
            _popupItem(colors, Icons.search_rounded, 'Search'),
            _popupItem(colors, Icons.wallpaper_outlined, 'Wallpaper'),
            _popupItem(colors, Icons.notifications_off_outlined, 'Mute'),
            _popupItem(colors, Icons.block_outlined, 'Block'),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _popupItem(AppColors colors, IconData icon, String label) {
    return PopupMenuItem(
      value: label,
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: colors.textSecondary),
          SizedBox(width: 10.w),
          Text(
            label,
            style: AppTextStyles.w500.copyWith(fontSize: 14.sp, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }

  // ── Message List ─────────────────────────────

  Widget _buildMessageList(AppColors colors) {
    final displayMessages = _filteredMessages;
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: displayMessages.length,
      itemBuilder: (context, i) {
        final msg = displayMessages[i];
        final prev = i > 0 ? displayMessages[i - 1] : null;
        final showDate = prev == null || prev.time.substring(3) != msg.time.substring(3);

        Widget tile = SwipeableMessage(
          key: _messageKeys[msg.id],
          message: msg,
          colors: colors,
          isHighlighted: _highlightedId == msg.id,
          onSwipe: () => setState(() => _replyingTo = msg),
          onReplyTap: () {
            if (msg.replyTo != null) {
              _onQuoteTap(msg.replyTo!.id);
            }
          },
          onReact: (emoji) => _addReaction(msg, emoji),
          onLongPress: () => _showMessageOptions(msg, colors),
        );

        if (_isSearching && _searchQuery.isNotEmpty) {
          tile = GestureDetector(
            onTap: () => _onSearchResultTap(msg),
            behavior: HitTestBehavior.opaque,
            child: tile,
          );
        }

        return Column(
          children: [
            if (showDate && i == 0) DateChip(label: 'Today', colors: colors),
            tile,
          ],
        );
      },
    );
  }

  Widget _buildScrollDownButton(AppColors colors) {
    return Positioned(
      bottom: 12.h,
      right: 16.w,
      child: GestureDetector(
        onTap: () => _scrollToBottom(animated: true),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: colors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: colors.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Icon(Icons.keyboard_arrow_down_rounded, color: colors.primary, size: 22.sp),
        ),
      ),
    );
  }

  // ── Reply Banner ─────────────────────────────

  Widget _buildReplyBanner(AppColors colors) {
    final msg = _replyingTo!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.border, width: 0.5),
          left: BorderSide(color: colors.primary, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.isMine ? 'You' : widget.contactName,
                  style: AppTextStyles.w600.copyWith(fontSize: 13.sp, color: colors.primary),
                ),
                SizedBox(height: 2.h),
                Text(
                  msg.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.w400.copyWith(fontSize: 13.sp, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _replyingTo = null),
            child: Icon(Icons.close_rounded, color: colors.textTertiary, size: 20.sp),
          ),
        ],
      ),
    );
  }

  // ── Input Bar ────────────────────────────────

  Widget _buildInputBar(AppColors colors) {
    final isFocused = _inputFocus.hasFocus;
    final fillColor = colors.isDarkMode ? colors.card : colors.surface;
    final actionColor = isFocused || _isTyping ? colors.primary : colors.textTertiary;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border, width: 0.6)),
      ),
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 8.h,
        bottom: MediaQuery.of(context).padding.bottom + 8.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 120.h),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: isFocused ? colors.primary : Colors.transparent,
                    width: 1.4,
                  ),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: colors.isDarkMode ? 0.22 : 0.14),
                            blurRadius: 14,
                            spreadRadius: 0.5,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: colors.isDarkMode ? 0.28 : 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 4.w, bottom: 3.h),
                      child: IconButton(
                        icon: Icon(Icons.emoji_emotions_outlined, color: actionColor, size: 23.sp),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 34.w, minHeight: 34.h),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        focusNode: _inputFocus,
                        maxLines: null,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.newline,
                        enableInlinePrediction: true,
                        enableInteractiveSelection: true,
                        style: AppTextStyles.w400.copyWith(fontSize: 15.sp, color: colors.textPrimary),
                        contextMenuBuilder: (context, editableTextState) {
                          return _ChatTextSelectionMenu(
                            editableTextState: editableTextState,
                            colors: colors,
                            controller: _inputController,
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: AppTextStyles.w400.copyWith(fontSize: 15.sp, color: colors.textTertiary),
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(4.w, 11.h, 8.w, 11.h),
                          filled: true,
                          fillColor: colors.background,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 5.w, bottom: 5.h),
                      child: IconButton(
                        icon: Icon(Icons.attach_file_rounded, color: actionColor, size: 20.sp),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                        style: IconButton.styleFrom(
                          backgroundColor: isFocused ? colors.primaryMuted : Colors.transparent,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: _isTyping
                ? SendButton(key: const ValueKey('send'), colors: colors, onTap: _sendMessage)
                : MicButton(key: const ValueKey('mic'), colors: colors),
          ),
        ],
      ),
    );
  }

  // ── Message Options ──────────────────────────

  Future<void> _showMessageOptions(ChatMessage msg, AppColors colors) async {
    await HapticFeedback.mediumImpact();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MessageOptionsSheet(
        message: msg,
        colors: colors,
        contactName: widget.contactName,
        onReply: () {
          context.pop();
          setState(() => _replyingTo = msg);
          _inputFocus.requestFocus();
        },
        onCopy: () async {
          await Clipboard.setData(ClipboardData(text: msg.text));
          if (!mounted) return;
          context.pop();
        },
        onReact: (emoji) {
          context.pop();
          _addReaction(msg, emoji);
        },
      ),
    );
  }
}

/// Drop-in replacement for [TextField]'s default selection toolbar.
/// Keeps the platform's native Cut / Copy / Paste / Select all buttons
/// and appends Bold / Italic / Strikethrough / Mono — each one wraps the
/// current selection with the matching WhatsApp-style delimiter and then
/// dismisses the menu, the same way a real cut/copy action would.
class _ChatTextSelectionMenu extends StatelessWidget {
  const _ChatTextSelectionMenu({
    required this.editableTextState,
    required this.colors,
    required this.controller,
  });

  final EditableTextState editableTextState;
  final AppColors colors;
  final TextEditingController controller;

  static const _formats = <(String label, String marker, bool multiline)>[
    ('Bold', '*', false),
    ('Italic', '_', false),
    ('Strikethrough', '~', false),
    ('Mono', '`', false),
    ('Code block', '```', true),
  ];

  void _wrap(String marker, {bool multiline = false}) {
    final text = controller.text;
    final selection = controller.selection;

    if (!selection.isValid || selection.isCollapsed) {
      editableTextState.hideToolbar();
      return;
    }

    final start = selection.start;
    final end = selection.end;
    final selectedText = text.substring(start, end);
    final useNewlines = multiline && selectedText.contains('\n');
    final wrapped = useNewlines ? '$marker\n$selectedText\n$marker' : '$marker$selectedText$marker';

    final newText = text.replaceRange(start, end, wrapped);
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: start + wrapped.length),
    );
    editableTextState.hideToolbar();
  }

  @override
  Widget build(BuildContext context) {
    final defaultItems = editableTextState.contextMenuButtonItems;

    final formatItems = [
      for (final format in _formats)
        ContextMenuButtonItem(
          label: format.$1,
          onPressed: () => _wrap(format.$2, multiline: format.$3),
        ),
    ];

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: [...defaultItems, ...formatItems],
    );
  }
}
