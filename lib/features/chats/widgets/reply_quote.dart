import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/chats/data/chat_message_model.dart';

class ReplyQuote extends StatelessWidget {
  const ReplyQuote({
    required this.original,
    required this.isMine,
    required this.colors,
    required this.contactName,
    super.key,
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
