import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';

class DateChip extends StatelessWidget {
  const DateChip({
    required this.label,
    required this.colors,
    super.key,
  });
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
