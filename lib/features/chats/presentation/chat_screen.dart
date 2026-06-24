import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_chat/config/routes/app_routes.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/chats/data/chat_data.dart';
import 'package:pulse_chat/features/chats/data/chat_message_model.dart';
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
    _messages = ChatMessageData().buildSampleMessages();
    for (final m in _messages) {
      _messageKeys[m.id] = GlobalKey();
    }
    _inputController.addListener(() {
      final t = _inputController.text.trim().isNotEmpty;
      if (t != _isTyping) setState(() => _isTyping = t);
    });
    _inputFocus.addListener(() {
      if (mounted) setState(() {});
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
            if (showDate && i == 0) DateChip(label: 'Today', colors: colors),
            SwipeableMessage(
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
    final isFocused = _inputFocus.hasFocus;
    final composerColor = colors.isDarkMode ? colors.card : colors.surface;
    final borderColor = isFocused ? colors.primary : colors.border.withValues(alpha: colors.isDarkMode ? 0.7 : 0.9);
    final actionColor = isFocused || _isTyping ? colors.primary : colors.textTertiary;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: colors.isDarkMode ? 0.18 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
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
            icon: Icon(Icons.emoji_emotions_outlined, color: actionColor, size: 24.sp),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 120.h),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: composerColor,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: borderColor, width: isFocused ? 1.4 : 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: colors.isDarkMode ? 0.22 : 0.06),
                      blurRadius: isFocused ? 14 : 8,
                      offset: const Offset(0, 3),
                    ),
                    if (isFocused)
                      BoxShadow(
                        color: colors.primary.withValues(alpha: colors.isDarkMode ? 0.18 : 0.12),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                  ],
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
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(16.w, 11.h, 8.w, 11.h),
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
