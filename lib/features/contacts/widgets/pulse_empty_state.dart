import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';

/// Calm, icon-led empty state. Each call site gives its own icon/copy so
/// the "no search results yet" state reads differently from "no pending
/// requests" — an empty screen should say something useful, not just
/// look sad.
class PulseEmptyState extends StatelessWidget {
  const PulseEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88.r,
            height: 88.r,
            decoration: BoxDecoration(
              color: colors.primaryMuted,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 38.sp, color: colors.primary),
          ),
          SizedBox(height: 20.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.w600.copyWith(fontSize: 16.sp, color: colors.textPrimary),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.w400.copyWith(fontSize: 13.sp, color: colors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
