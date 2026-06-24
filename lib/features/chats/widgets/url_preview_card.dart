import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/chats/data/chat_message_model.dart';

class UrlPreviewCard extends StatelessWidget {
  const UrlPreviewCard({
    required this.data,
    required this.isMine,
    required this.colors,
    super.key,
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
