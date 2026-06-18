import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.label = 'or continue with email'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Row(
      children: [
        Expanded(child: Divider(color: colors.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            label,
            style: AppTextStyles.w500.copyWith(fontSize: 12.5.sp, color: colors.textTertiary),
          ),
        ),
        Expanded(child: Divider(color: colors.border, thickness: 1)),
      ],
    );
  }
}
