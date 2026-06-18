import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';

/// Primary call-to-action for the auth flow. Uses a coral-to-secondary
/// diagonal gradient so the app's two brand colors meet in the single
/// most-pressed element on screen, reinforcing "Pulse" (two signals
/// converging) without literal iconography.
class PulseButton extends StatelessWidget {
  const PulseButton({super.key, required this.label, required this.onPressed, this.isLoading = false});

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Material(
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: isLoading ? null : onPressed,
        child: Container(
          height: 56.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.primary, colors.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: colors.isDarkMode ? 0.25 : 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isLoading
              ? SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: const CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                )
              : Text(
                  label,
                  style: AppTextStyles.w600.copyWith(fontSize: 16.sp, color: Colors.white, letterSpacing: 0.3),
                ),
        ),
      ),
    );
  }
}
