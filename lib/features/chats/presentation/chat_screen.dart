import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_chat/config/routes/app_routes.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';

// ─────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────

enum MessageStatus { sending, sent, delivered, read }

class UrlPreviewData {
  const UrlPreviewData({
    required this.url,
    required this.title,
    required this.description,
    required this.siteName,
    this.imageUrl,
  });
  final String url;
  final String title;
  final String description;
  final String? imageUrl;
  final String siteName;
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    required this.isMine,
    required this.time,
    this.status = MessageStatus.read,
    this.replyTo,
    this.reactions = const {},
    this.urlPreview,
    this.isDeleted = false,
  });

  final String id;
  final String text;
  final bool isMine;
  final String time;
  final MessageStatus status;
  final ChatMessage? replyTo;
  Map<String, List<String>> reactions; // emoji -> [userIds]
  final UrlPreviewData? urlPreview;
  final bool isDeleted;
}

// ─────────────────────────────────────────────
// Sample Data
// ─────────────────────────────────────────────

const _urlPreview = UrlPreviewData(
  url: 'https://flutter.dev/multi-platform',
  title: 'Flutter – Build apps for any screen',
  description:
      'Flutter transforms the app development process. Build, test, and deploy beautiful mobile, web, desktop, and embedded apps from a single codebase.',
  siteName: 'flutter.dev',
);

List<ChatMessage> _buildSampleMessages() {
  final m = <ChatMessage>[];

  final m1 = ChatMessage(
    id: '1',
    text: 'Hey! Did you check out the Flutter 3.x release notes?',
    isMine: false,
    time: '9:01 AM',
  );
  m.add(m1);

  final m2 = ChatMessage(
    id: '2',
    text: 'Yeah! The performance improvements are insane 🔥',
    isMine: true,
    time: '9:02 AM',
    reactions: {
      '🔥': ['me', 'them'],
      '👍': ['them'],
    },
  );
  m.add(m2);

  final m3 = ChatMessage(
    id: '3',
    text: 'Check this out — https://flutter.dev/multi-platform',
    isMine: false,
    time: '9:04 AM',
    urlPreview: _urlPreview,
  );
  m.add(m3);

  final m4 = ChatMessage(
    id: '4',
    text: 'This is exactly what I needed for the project!',
    isMine: true,
    time: '9:05 AM',
    replyTo: m3,
  );
  m.add(m4);

  final m5 = ChatMessage(
    id: '5',
    text: 'Are you planning to migrate the existing codebase?',
    isMine: false,
    time: '9:06 AM',
  );
  m.add(m5);

  final m6 = ChatMessage(
    id: '6',
    text: 'Yep, starting with the home screen first. Should be smooth.',
    isMine: true,
    time: '9:08 AM',
    replyTo: m5,
    reactions: {
      '❤️': ['them'],
    },
  );
  m.add(m6);

  final m7 = ChatMessage(
    id: '7',
    text: 'Let me know if you need help with the state management setup',
    isMine: false,
    time: '9:10 AM',
  );
  m.add(m7);

  final m8 = ChatMessage(
    id: '8',
    text: 'For sure! I was thinking of going with Riverpod this time',
    isMine: true,
    time: '9:12 AM',
    status: MessageStatus.delivered,
  );
  m.add(m8);

  final m9 = ChatMessage(
    id: '9',
    text: 'Great choice 👌 Riverpod 2.0 is much cleaner than Provider',
    isMine: false,
    time: '9:13 AM',
    reactions: {
      '👌': ['me'],
    },
  );
  m.add(m9);

  final m10 = ChatMessage(
    id: '10',
    text: 'Agreed. The ref.watch pattern makes rebuilds so predictable 😍',
    isMine: true,
    time: '9:15 AM',
    status: MessageStatus.sent,
  );
  m.add(m10);

  return m;
}

// ─────────────────────────────────────────────
// Chat Screen
// ─────────────────────────────────────────────

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.contactName = 'Aanya Sharma',
    this.isOnline = true,
    this.isGroup = false,
  });

  final String contactName;
  final bool isOnline;
  final bool isGroup;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<ChatMessage> _messages;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  ChatMessage? _replyingTo;
  bool _showScrollDown = false;
  bool _isTyping = false;

  // Map messageId → GlobalKey so we can scroll to it
  final Map<String, GlobalKey> _messageKeys = {};

  @override
  void initState() {
    super.initState();
    _messages = _buildSampleMessages();
    for (final m in _messages) {
      _messageKeys[m.id] = GlobalKey();
    }
    _inputController.addListener(() {
      final t = _inputController.text.trim().isNotEmpty;
      if (t != _isTyping) setState(() => _isTyping = t);
    });
    _scrollController.addListener(() {
      final show = _scrollController.offset > 200;
      if (show != _showScrollDown) setState(() => _showScrollDown = show);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
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

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isMine: true,
      time: _formatNow(),
      status: MessageStatus.sending,
      replyTo: _replyingTo,
    );
    _messageKeys[msg.id] = GlobalKey();

    setState(() {
      _messages.add(msg);
      _replyingTo = null;
    });
    _inputController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animated: true));
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

  String _formatNow() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Scaffold(
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
    );
  }

  // ── App Bar ──────────────────────────────────

  PreferredSizeWidget _buildAppBar(AppColors colors) {
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
          _MiniAvatar(name: widget.contactName, colors: colors),
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
                  widget.isOnline ? 'Online' : 'Last seen recently',
                  style: AppTextStyles.w400.copyWith(
                    fontSize: 12.sp,
                    color: widget.isOnline ? colors.success : colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
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
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final msg = _messages[i];
        final prev = i > 0 ? _messages[i - 1] : null;
        final showDate = prev == null || prev.time.substring(3) != msg.time.substring(3);
        return Column(
          children: [
            if (showDate && i == 0) _DateChip(label: 'Today', colors: colors),
            _SwipeableMessage(
              key: _messageKeys[msg.id],
              message: msg,
              colors: colors,
              isHighlighted: _highlightedId == msg.id,
              onSwipe: () => setState(() => _replyingTo = msg),
              onReplyTap: () => _scrollToMessage(msg.replyTo!.id),
              onReact: (emoji) => _addReaction(msg, emoji),
              onLongPress: () => _showMessageOptions(msg, colors),
            ),
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
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
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
          IconButton(
            icon: Icon(Icons.emoji_emotions_outlined, color: colors.textTertiary, size: 24.sp),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 120.h),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        focusNode: _inputFocus,
                        maxLines: null,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        style: AppTextStyles.w400.copyWith(fontSize: 15.sp, color: colors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: AppTextStyles.w400.copyWith(fontSize: 15.sp, color: colors.textTertiary),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 4.w, bottom: 4.h),
                      child: IconButton(
                        icon: Icon(Icons.attach_file_rounded, color: colors.textTertiary, size: 20.sp),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
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
                ? _SendButton(key: const ValueKey('send'), colors: colors, onTap: _sendMessage)
                : _MicButton(key: const ValueKey('mic'), colors: colors),
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
      builder: (_) => _MessageOptionsSheet(
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

// ─────────────────────────────────────────────
// Swipeable Message Wrapper
// ─────────────────────────────────────────────

class _SwipeableMessage extends StatefulWidget {
  const _SwipeableMessage({
    required this.message,
    required this.colors,
    required this.isHighlighted,
    required this.onSwipe,
    required this.onReplyTap,
    required this.onReact,
    required this.onLongPress,
    super.key,
  });

  final ChatMessage message;
  final AppColors colors;
  final bool isHighlighted;
  final VoidCallback onSwipe;
  final VoidCallback onReplyTap;
  final ValueChanged<String> onReact;
  final VoidCallback onLongPress;

  @override
  State<_SwipeableMessage> createState() => _SwipeableMessageState();
}

class _SwipeableMessageState extends State<_SwipeableMessage> with SingleTickerProviderStateMixin {
  late AnimationController _swipeAnim;
  double _dragX = 0;
  bool _triggered = false;

  static const double _triggerThreshold = 60;

  @override
  void initState() {
    super.initState();
    _swipeAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _swipeAnim.dispose();
    super.dispose();
  }

  Future<void> _onDragUpdate(DragUpdateDetails d) async {
    final isMine = widget.message.isMine;
    final delta = d.delta.dx;

    if (isMine && delta < 0) {
      setState(() => _dragX = math.max(-_triggerThreshold * 1.2, _dragX + delta));
    } else if (!isMine && delta > 0) {
      setState(() => _dragX = math.min(_triggerThreshold * 1.2, _dragX + delta));
    }

    final abs = _dragX.abs();
    if (abs >= _triggerThreshold && !_triggered) {
      _triggered = true;
      await HapticFeedback.lightImpact();
      widget.onSwipe();
    }
  }

  void _onDragEnd(DragEndDetails _) {
    setState(() {
      _dragX = 0;
      _triggered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    final progress = (_dragX.abs() / _triggerThreshold).clamp(0.0, 1.0);
    final isMine = msg.isMine;

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: widget.isHighlighted ? widget.colors.primaryMuted.withValues(alpha: 0.6) : Colors.transparent,
        child: Stack(
          children: [
            // Reply arrow icon revealed behind
            Positioned(
              left: isMine ? null : 8.w,
              right: isMine ? 8.w : null,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: progress,
                child: Center(
                  child: Transform.scale(
                    scale: 0.6 + 0.4 * progress,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: widget.colors.primaryMuted,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.reply_rounded,
                        size: 16.sp,
                        color: widget.colors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Message bubble sliding
            Transform.translate(
              offset: Offset(_dragX, 0),
              child: _MessageBubble(
                message: msg,
                colors: widget.colors,
                contactName: 'Aanya',
                onReplyTap: msg.replyTo != null ? widget.onReplyTap : null,
                onReact: widget.onReact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Message Bubble
// ─────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.colors,
    required this.contactName,
    required this.onReact,
    this.onReplyTap,
  });

  final ChatMessage message;
  final AppColors colors;
  final String contactName;
  final VoidCallback? onReplyTap;
  final ValueChanged<String> onReact;

  static const double _kBubbleMaxWidth = 0.75;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final screenW = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(
        top: 2.h,
        bottom: message.reactions.isNotEmpty ? 20.h : 4.h,
      ),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: screenW * _kBubbleMaxWidth),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Bubble
                  Container(
                    decoration: BoxDecoration(
                      color: isMine ? colors.primary : colors.card,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.r),
                        topRight: Radius.circular(18.r),
                        bottomLeft: Radius.circular(isMine ? 18.r : 4.r),
                        bottomRight: Radius.circular(isMine ? 4.r : 18.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reply quote
                        if (message.replyTo != null)
                          _ReplyQuote(
                            original: message.replyTo!,
                            isMine: isMine,
                            colors: colors,
                            contactName: contactName,
                            onTap: onReplyTap,
                          ),
                        // URL preview
                        if (message.urlPreview != null)
                          _UrlPreviewCard(
                            data: message.urlPreview!,
                            isMine: isMine,
                            colors: colors,
                          ),
                        // Text
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            12.w,
                            message.replyTo == null && message.urlPreview == null ? 10.h : 6.h,
                            12.w,
                            6.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  message.text,
                                  style: AppTextStyles.w400.copyWith(
                                    fontSize: 15.sp,
                                    color: isMine ? Colors.white : colors.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    message.time,
                                    style: AppTextStyles.w400.copyWith(
                                      fontSize: 10.sp,
                                      color: isMine ? Colors.white.withValues(alpha: 0.7) : colors.textTertiary,
                                    ),
                                  ),
                                  if (isMine) ...[
                                    SizedBox(width: 3.w),
                                    _StatusIcon(status: message.status, colors: colors),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Reactions
              if (message.reactions.isNotEmpty)
                Positioned(
                  bottom: -14.h,
                  right: isMine ? 4.w : null,
                  left: isMine ? null : 4.w,
                  child: _ReactionsRow(
                    reactions: message.reactions,
                    isMine: isMine,
                    colors: colors,
                    onTap: onReact,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reply Quote inside bubble
// ─────────────────────────────────────────────

class _ReplyQuote extends StatelessWidget {
  const _ReplyQuote({
    required this.original,
    required this.isMine,
    required this.colors,
    required this.contactName,
    this.onTap,
  });

  final ChatMessage original;
  final bool isMine;
  final AppColors colors;
  final String contactName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isMine ? Colors.white.withValues(alpha: 0.15) : colors.primaryMuted.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(6.w, 6.h, 6.w, 0),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border(
            left: BorderSide(
              color: isMine ? Colors.white.withValues(alpha: 0.6) : colors.primary,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              original.isMine ? 'You' : contactName,
              style: AppTextStyles.w600.copyWith(
                fontSize: 12.sp,
                color: isMine ? Colors.white : colors.primary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              original.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.w400.copyWith(
                fontSize: 12.sp,
                color: isMine ? Colors.white.withValues(alpha: 0.8) : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// URL Preview Card
// ─────────────────────────────────────────────

class _UrlPreviewCard extends StatelessWidget {
  const _UrlPreviewCard({
    required this.data,
    required this.isMine,
    required this.colors,
  });

  final UrlPreviewData data;
  final bool isMine;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final bgColor = isMine ? Colors.white.withValues(alpha: 0.12) : colors.primaryMuted;
    final titleColor = isMine ? Colors.white : colors.textPrimary;
    final subColor = isMine ? Colors.white.withValues(alpha: 0.7) : colors.textSecondary;
    final siteColor = isMine ? Colors.white.withValues(alpha: 0.6) : colors.primary;

    return Container(
      margin: EdgeInsets.fromLTRB(6.w, 6.h, 6.w, 0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(
          left: BorderSide(
            color: isMine ? Colors.white.withValues(alpha: 0.5) : colors.secondary,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
              child: Image.network(
                data.imageUrl!,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 80.h,
                  color: colors.border,
                  child: Icon(Icons.broken_image_outlined, color: colors.textTertiary),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.language_rounded, size: 11.sp, color: siteColor),
                    SizedBox(width: 4.w),
                    Text(
                      data.siteName,
                      style: AppTextStyles.w600.copyWith(fontSize: 11.sp, color: siteColor),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.w600.copyWith(fontSize: 13.sp, color: titleColor),
                ),
                SizedBox(height: 3.h),
                Text(
                  data.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.w400.copyWith(fontSize: 11.sp, color: subColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reactions Row
// ─────────────────────────────────────────────

class _ReactionsRow extends StatelessWidget {
  const _ReactionsRow({
    required this.reactions,
    required this.isMine,
    required this.colors,
    required this.onTap,
  });

  final Map<String, List<String>> reactions;
  final bool isMine;
  final AppColors colors;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: reactions.entries.map((e) {
        final iReacted = e.value.contains('me');
        return GestureDetector(
          onTap: () => onTap(e.key),
          child: Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: iReacted ? colors.primaryMuted : colors.card,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: iReacted ? colors.primary : colors.border,
                width: iReacted ? 1.5 : 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.key, style: TextStyle(fontSize: 13.sp)),
                if (e.value.length > 1) ...[
                  SizedBox(width: 3.w),
                  Text(
                    '${e.value.length}',
                    style: AppTextStyles.w600.copyWith(
                      fontSize: 11.sp,
                      color: iReacted ? colors.primary : colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// Message Options Bottom Sheet
// ─────────────────────────────────────────────

class _MessageOptionsSheet extends StatelessWidget {
  const _MessageOptionsSheet({
    required this.message,
    required this.colors,
    required this.contactName,
    required this.onReply,
    required this.onCopy,
    required this.onReact,
  });

  final ChatMessage message;
  final AppColors colors;
  final String contactName;
  final VoidCallback onReply;
  final VoidCallback onCopy;
  final ValueChanged<String> onReact;

  static const List<String> _quickReactions = [
    '❤️',
    '😂',
    '😮',
    '😢',
    '👍',
    '🙏',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick emoji row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _quickReactions.map((e) {
                final reacted = message.reactions[e]?.contains('me') ?? false;
                return GestureDetector(
                  onTap: () => onReact(e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: reacted ? colors.primaryMuted : colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: reacted ? colors.primary : colors.border,
                      ),
                    ),
                    child: Text(e, style: TextStyle(fontSize: 22.sp)),
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, color: colors.border),
          // Preview of selected message
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.isMine ? 'You' : contactName,
                        style: AppTextStyles.w600.copyWith(fontSize: 12.sp, color: colors.primary),
                      ),
                      Text(
                        message.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.w400.copyWith(fontSize: 13.sp, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.border),
          // Action buttons
          _OptionTile(
            icon: Icons.reply_rounded,
            label: 'Reply',
            colors: colors,
            onTap: onReply,
          ),
          _OptionTile(
            icon: Icons.copy_rounded,
            label: 'Copy',
            colors: colors,
            onTap: onCopy,
          ),
          _OptionTile(
            icon: Icons.forward_rounded,
            label: 'Forward',
            colors: colors,
            onTap: () => context.pop(),
          ),
          _OptionTile(
            icon: Icons.info_outline_rounded,
            label: 'Info',
            colors: colors,
            onTap: () => context.pop(),
          ),
          _OptionTile(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            colors: colors,
            isDestructive: true,
            onTap: () => context.pop(),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final AppColors colors;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? colors.error : colors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: color),
            SizedBox(width: 14.w),
            Text(
              label,
              style: AppTextStyles.w500.copyWith(fontSize: 15.sp, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Status Icon
// ─────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status, required this.colors});
  final MessageStatus status;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return Icon(Icons.access_time_rounded, size: 12.sp, color: Colors.white.withValues(alpha: 0.7));
      case MessageStatus.sent:
        return Icon(Icons.check_rounded, size: 13.sp, color: Colors.white.withValues(alpha: 0.7));
      case MessageStatus.delivered:
        return Icon(Icons.done_all_rounded, size: 13.sp, color: Colors.white.withValues(alpha: 0.7));
      case MessageStatus.read:
        return Icon(Icons.done_all_rounded, size: 13.sp, color: Colors.white);
    }
  }
}

// ─────────────────────────────────────────────
// Send / Mic buttons
// ─────────────────────────────────────────────

class _SendButton extends StatelessWidget {
  const _SendButton({required this.colors, required this.onTap, super.key});
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.send_rounded, color: Colors.white, size: 20.sp),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.colors, super.key});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: colors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.mic_rounded, color: Colors.white, size: 22.sp),
    );
  }
}

// ─────────────────────────────────────────────
// Mini Avatar (AppBar)
// ─────────────────────────────────────────────

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.name, required this.colors});
  final String name;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();
    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primaryMuted,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.w700.copyWith(fontSize: 14.sp, color: colors.primary),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Date Chip
// ─────────────────────────────────────────────

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label, required this.colors});
  final String label;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Text(
          label,
          style: AppTextStyles.w500.copyWith(fontSize: 12.sp, color: colors.textTertiary),
        ),
      ),
    );
  }
}
