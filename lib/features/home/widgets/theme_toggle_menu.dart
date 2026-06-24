import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';

class ThemeToggleMenuRow extends StatelessWidget {
  const ThemeToggleMenuRow({
    required this.colors,
    required this.isDark,
    required this.onChanged,
    super.key,
  });

  final AppColors colors;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isDark),
      child: SizedBox(
        height: 52.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                size: 20.sp,
                color: colors.textSecondary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Dark theme',
                  style: AppTextStyles.w500.copyWith(
                    fontSize: 14.sp,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Switch.adaptive(
                value: isDark,
                activeThumbColor: colors.primary,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
