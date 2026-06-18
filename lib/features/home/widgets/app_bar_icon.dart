import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';

class AppBarIcon extends StatelessWidget {
  const AppBarIcon({
    required this.icon,
    required this.colors,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Icon(icon, color: colors.textPrimary, size: 18.sp),
      ),
    );
  }
}
