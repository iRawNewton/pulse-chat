import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/profile/profile_models.dart';

/// The primary CTA on a visitor's view of someone else's profile.
/// Swaps appearance based on [status]:
///  - none            -> filled coral "Send Request"
///  - requestSent     -> muted/disabled-looking "Request Sent"
///  - requestReceived -> "Accept Request" (their request to me)
///  - connected       -> outlined "Message"
class ConnectionActionButton extends StatelessWidget {
  const ConnectionActionButton({required this.status, required this.onPrimaryTap, super.key});

  final ConnectionStatus status;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    switch (status) {
      case ConnectionStatus.none:
        return _buildButton(
          context,
          label: 'Send Request',
          icon: Icons.person_add_rounded,
          background: colors.primary,
          foreground: Colors.white,
          onTap: onPrimaryTap,
        );

      case ConnectionStatus.requestSent:
        return _buildButton(
          context,
          label: 'Request Sent',
          icon: Icons.check_circle_outline_rounded,
          background: colors.surface,
          foreground: colors.textSecondary,
          border: colors.border,
          onTap: null, // already sent — no-op until backend supports cancel
        );

      case ConnectionStatus.requestReceived:
        return _buildButton(
          context,
          label: 'Accept Request',
          icon: Icons.how_to_reg_rounded,
          background: colors.secondary,
          foreground: Colors.white,
          onTap: onPrimaryTap,
        );

      case ConnectionStatus.connected:
        return _buildButton(
          context,
          label: 'Message',
          icon: Icons.chat_bubble_rounded,
          background: colors.primary,
          foreground: Colors.white,
          onTap: onPrimaryTap,
        );
    }
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color background,
    required Color foreground,
    Color? border,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: border != null ? Border.all(color: border) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 19.sp, color: foreground),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: AppTextStyles.w600.copyWith(fontSize: 15.sp, color: foreground, letterSpacing: 0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
