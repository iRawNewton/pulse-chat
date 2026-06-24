import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/features/chats/data/chat_message_model.dart';
import 'package:pulse_chat/features/chats/widgets/message_bubble.dart';

class SwipeableMessage extends StatefulWidget {
  const SwipeableMessage({
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
  State<SwipeableMessage> createState() => SwipeableMessageState();
}

class SwipeableMessageState extends State<SwipeableMessage> with SingleTickerProviderStateMixin {
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
              child: MessageBubble(
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
