import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';

/// Outlined "Continue with Google" button. Uses the project's own
/// asset (assets/icons/google_logo.png) rather than drawing the G mark,
/// per brand guidelines on third-party logos. Styled as a calm, neutral
/// surface — deliberately quieter than the coral primary button so the
/// email/password path reads as the primary action and Google as the
/// fast alternative.
class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({required this.label, required this.onPressed, super.key, this.isLoading = false});

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: isLoading ? null : onPressed,
        child: Container(
          height: 56.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: colors.border, width: 1.2),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: colors.textSecondary),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/google_logo.svg',
                      width: 22.r,
                      height: 22.r,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      label,
                      style: AppTextStyles.w600.copyWith(fontSize: 15.sp, color: colors.textPrimary),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
