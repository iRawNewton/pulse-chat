import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/contacts/data/contact_status.dart';

/// Renders the correct action(s) for a user row based on [status], and
/// morphs between states with an [AnimatedSwitcher] so sending a request
/// visibly transforms the button into a "Pending" pill rather than
/// abruptly swapping it — this is the one place on the screen that gets
/// deliberate motion, everything else stays calm.
class ContactActionButton extends StatelessWidget {
  const ContactActionButton({
    super.key,
    required this.status,
    this.onSendRequest,
    this.onCancelRequest,
    this.onAccept,
    this.onReject,
    this.onMessage,
    this.onUnblock,
    this.dense = false,
  });

  final ContactStatus status;
  final VoidCallback? onSendRequest;
  final VoidCallback? onCancelRequest;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onMessage;
  final VoidCallback? onUnblock;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(status),
        child: _buildForStatus(context, colors),
      ),
    );
  }

  Widget _buildForStatus(BuildContext context, AppColors colors) {
    switch (status) {
      case ContactStatus.none:
        return _PrimaryPillButton(
          label: 'Add',
          icon: Icons.person_add_alt_1_rounded,
          color: colors.primary,
          onTap: onSendRequest,
          dense: dense,
        );

      case ContactStatus.pendingSent:
        return _OutlinePillButton(
          label: 'Pending',
          icon: Icons.schedule_rounded,
          color: colors.textSecondary,
          onTap: onCancelRequest,
          dense: dense,
        );

      case ContactStatus.pendingReceived:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IconCircleButton(
              icon: Icons.close_rounded,
              color: colors.error,
              backgroundColor: colors.errorMuted,
              onTap: onReject,
              dense: dense,
            ),
            SizedBox(width: 8.w),
            _IconCircleButton(
              icon: Icons.check_rounded,
              color: Colors.white,
              backgroundColor: colors.success,
              onTap: onAccept,
              dense: dense,
            ),
          ],
        );

      case ContactStatus.friends:
        return _OutlinePillButton(
          label: 'Message',
          icon: Icons.chat_bubble_outline_rounded,
          color: colors.secondary,
          onTap: onMessage,
          dense: dense,
        );

      case ContactStatus.blockedByMe:
        return _OutlinePillButton(
          label: 'Unblock',
          icon: Icons.lock_open_rounded,
          color: colors.textSecondary,
          onTap: onUnblock,
          dense: dense,
        );
    }
  }
}

class _PrimaryPillButton extends StatelessWidget {
  const _PrimaryPillButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.dense,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: dense ? 12.w : 16.w, vertical: dense ? 7.h : 9.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: dense ? 14.sp : 16.sp, color: Colors.white),
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppTextStyles.w600.copyWith(fontSize: dense ? 12.sp : 13.sp, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlinePillButton extends StatelessWidget {
  const _OutlinePillButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.dense,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: dense ? 12.w : 16.w, vertical: dense ? 7.h : 9.h),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: dense ? 14.sp : 16.sp, color: color),
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppTextStyles.w600.copyWith(fontSize: dense ? 12.sp : 13.sp, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
    required this.dense,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final dim = dense ? 32.r : 36.r;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(dim / 2),
        child: Container(
          width: dim,
          height: dim,
          decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, size: dense ? 16.sp : 18.sp, color: color),
        ),
      ),
    );
  }
}
