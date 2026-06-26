import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';

/// A styled text field for edit-profile forms — fully theme-aware,
/// with a label above the field (not a floating label) since that
/// reads better against the filled background in both modes.
class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.prefixText,
    this.readOnly = false,
    this.enabled = true,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final String? hint;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? prefixText;
  final bool readOnly;
  final bool enabled;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.w600.copyWith(fontSize: 12.5.sp, color: colors.textSecondary, letterSpacing: 0.2),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          readOnly: readOnly,
          enabled: enabled,
          style: AppTextStyles.w500.copyWith(fontSize: 15.sp, color: colors.textPrimary),
          cursorColor: colors.primary,
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            filled: true,
            fillColor: enabled ? colors.surface : colors.surface.withValues(alpha: 0.5),
            hintText: hint,
            hintStyle: AppTextStyles.w400.copyWith(fontSize: 14.sp, color: colors.textTertiary),
            prefixText: prefixText,
            prefixStyle: AppTextStyles.w500.copyWith(fontSize: 15.sp, color: colors.textSecondary),
            prefixIcon: icon != null
                ? Padding(
                    padding: EdgeInsets.only(left: 14.w, right: 10.w),
                    child: Icon(icon, size: 19.sp, color: colors.textTertiary),
                  )
                : null,
            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffix,
            contentPadding: EdgeInsets.symmetric(horizontal: icon != null ? 0 : 16.w, vertical: 15.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: colors.border),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: colors.border.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: colors.primary, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
