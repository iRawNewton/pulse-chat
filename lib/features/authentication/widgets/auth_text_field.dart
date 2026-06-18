import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';

/// Branded text field used across the auth flow. Built on top of the app's
/// InputDecorationTheme but with a few auth-specific touches: an optional
/// leading icon, a focus-driven label color shift toward primary, and a
/// password-visibility toggle when [obscureText] is provided.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured = widget.obscureText;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.w600.copyWith(
            fontSize: 13.sp,
            color: _focused ? colors.primary : colors.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: AppTextStyles.w500.copyWith(fontSize: 15.sp, color: colors.textPrimary),
          cursorColor: colors.primary,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.w400.copyWith(fontSize: 15.sp, color: colors.textTertiary),
            prefixIcon: widget.icon == null
                ? null
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: Icon(
                      widget.icon,
                      size: 20.r,
                      color: _focused ? colors.primary : colors.textTertiary,
                    ),
                  ),
            prefixIconConstraints: BoxConstraints(minWidth: 44.w, minHeight: 20.h),
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    icon: Icon(
                      _obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 20.r,
                      color: colors.textTertiary,
                    ),
                  )
                : null,
            filled: true,
            fillColor: colors.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: colors.primary, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: colors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: colors.error, width: 1.6),
            ),
            errorStyle: AppTextStyles.w500.copyWith(fontSize: 12.sp, color: colors.error),
          ),
        ),
      ],
    );
  }
}
