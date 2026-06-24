import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';

class MiniAvatar extends StatelessWidget {
  const MiniAvatar({
    required this.name,
    required this.colors,
    super.key,
  });
  final String name;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();
    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primaryMuted,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.w700.copyWith(fontSize: 14.sp, color: colors.primary),
        ),
      ),
    );
  }
}
