import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/profile/profile_models.dart';

/// Circular avatar that shows [photoUrl] when present, otherwise falls
/// back to initials on a gradient coral/teal background — colour is
/// derived deterministically from the name so the same user always gets
/// the same fallback colour.
///
/// Optionally renders an online-status dot in the bottom-right corner.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.name,
    required this.initials,
    this.photoUrl,
    this.size = 96,
    this.onlineStatus,
    this.showOnlineDot = false,
    this.borderColor,
    this.borderWidth = 3,
    super.key,
  });

  final String name;
  final String initials;
  final String? photoUrl;
  final double size;
  final OnlineStatus? onlineStatus;
  final bool showOnlineDot;
  final Color? borderColor;
  final double borderWidth;

  /// A few stable gradient pairs derived from the AppColors brand palette,
  /// picked by name hash so a given user is always the same colour.
  List<Color> _gradientFor(AppColors colors) {
    final gradients = <List<Color>>[
      [colors.primary, colors.primary.withValues(alpha: 0.65)],
      [colors.secondary, colors.secondary.withValues(alpha: 0.65)],
      [colors.info, colors.secondary],
      [colors.primary, colors.secondary],
    ];
    final index = name.isEmpty ? 0 : name.codeUnits.fold<int>(0, (a, b) => a + b) % gradients.length;
    return gradients[index];
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final dotSize = size * 0.28;

    return SizedBox(
      width: size.w,
      height: size.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size.w,
            height: size.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: borderColor != null ? Border.all(color: borderColor!, width: borderWidth.w) : null,
              gradient: photoUrl == null
                  ? LinearGradient(
                      colors: _gradientFor(colors),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              image: photoUrl != null ? DecorationImage(image: NetworkImage(photoUrl!), fit: BoxFit.cover) : null,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: photoUrl == null
                ? Center(
                    child: Text(
                      initials,
                      style: AppTextStyles.w700.copyWith(
                        fontSize: (size * 0.36).sp,
                        color: Colors.white,
                        letterSpacing: 0,
                      ),
                    ),
                  )
                : null,
          ),
          if (showOnlineDot && onlineStatus != null)
            Positioned(
              bottom: -dotSize.w * 0.05,
              right: -dotSize.w * 0.05,
              child: Container(
                width: dotSize.w,
                height: dotSize.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.background,
                  border: Border.all(color: colors.background, width: 2.5.w),
                ),
                child: Center(
                  child: Container(
                    width: (dotSize - 6).w,
                    height: (dotSize - 6).w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statusColor(colors, onlineStatus!),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _statusColor(AppColors colors, OnlineStatus status) {
    switch (status) {
      case OnlineStatus.online:
        return colors.success;
      case OnlineStatus.away:
        return colors.warning;
      case OnlineStatus.offline:
        return colors.textTertiary;
    }
  }
}
