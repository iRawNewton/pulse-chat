import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/chats/data/chat_message_model.dart';

class MessageOptionsSheet extends StatelessWidget {
  const MessageOptionsSheet({
    required this.message,
    required this.colors,
    required this.contactName,
    required this.onReply,
    required this.onCopy,
    required this.onReact,
    super.key,
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
          OptionTile(
            icon: Icons.reply_rounded,
            label: 'Reply',
            colors: colors,
            onTap: onReply,
          ),
          OptionTile(
            icon: Icons.copy_rounded,
            label: 'Copy',
            colors: colors,
            onTap: onCopy,
          ),
          OptionTile(
            icon: Icons.forward_rounded,
            label: 'Forward',
            colors: colors,
            onTap: () => context.pop(),
          ),
          OptionTile(
            icon: Icons.info_outline_rounded,
            label: 'Info',
            colors: colors,
            onTap: () => context.pop(),
          ),
          OptionTile(
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

class OptionTile extends StatelessWidget {
  const OptionTile({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
    super.key,
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
