import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';

class MicButton extends StatelessWidget {
  const MicButton({required this.colors, super.key});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: colors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.mic_rounded, color: Colors.white, size: 22.sp),
    );
  }
}
