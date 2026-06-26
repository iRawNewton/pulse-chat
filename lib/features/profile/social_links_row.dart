import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/profile/profile_models.dart';

class _PlatformMeta {
  const _PlatformMeta(this.icon, this.label, this.brandColor);
  final IconData icon;
  final String label;
  final Color brandColor;
}

const Map<SocialPlatform, _PlatformMeta> _platformMeta = {
  SocialPlatform.facebook: _PlatformMeta(Icons.facebook_rounded, 'Facebook', Color(0xFF1877F2)),
  SocialPlatform.x: _PlatformMeta(Icons.close_rounded, 'X', Color(0xFF000000)),
  SocialPlatform.instagram: _PlatformMeta(Icons.camera_alt_rounded, 'Instagram', Color(0xFFE1306C)),
  SocialPlatform.snapchat: _PlatformMeta(Icons.camera_rounded, 'Snapchat', Color(0xFFFFFC00)),
  SocialPlatform.linkedin: _PlatformMeta(Icons.work_rounded, 'LinkedIn', Color(0xFF0A66C2)),
};

/// Row of circular icon buttons for the fixed social platforms the user
/// has actually filled in, plus a trailing chip for the single custom
/// link if present. Tapping calls [onTap] with the URL — launching it
/// (url_launcher) is left to the integration layer.
class SocialLinksRow extends StatelessWidget {
  const SocialLinksRow({
    required this.links,
    required this.onTap,
    this.customUrl,
    super.key,
  });

  final List<SocialLink> links;
  final String? customUrl;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    if (links.isEmpty && customUrl == null) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        for (final link in links)
          _SocialIconButton(
            meta: _platformMeta[link.platform]!,
            isDark: colors.isDarkMode,
            onTap: () => onTap(link.url),
          ),
        if (customUrl != null && customUrl!.isNotEmpty) _CustomLinkChip(url: customUrl!, onTap: () => onTap(customUrl!)),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({required this.meta, required this.isDark, required this.onTap});
  final _PlatformMeta meta;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    // Snapchat's brand yellow is unreadable on light surfaces with a
    // light icon, so flip the icon to near-black for that one case.
    final iconColor = meta.brandColor == const Color(0xFFFFFC00) ? const Color(0xFF1A1718) : Colors.white;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: meta.brandColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: colors.border.withValues(alpha: isDark ? 0.4 : 0), width: 1),
          ),
          child: Icon(meta.icon, color: iconColor, size: 20.sp),
        ),
      ),
    );
  }
}

class _CustomLinkChip extends StatelessWidget {
  const _CustomLinkChip({required this.url, required this.onTap});
  final String url;
  final VoidCallback onTap;

  String get _shortUrl {
    var u = url.replaceFirst(RegExp(r'^https?://'), '').replaceFirst('www.', '');
    if (u.length > 22) u = '${u.substring(0, 22)}…';
    return u;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          height: 44.w,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: colors.secondaryMuted,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: colors.secondary.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link_rounded, size: 18.sp, color: colors.secondary),
              SizedBox(width: 6.w),
              Text(
                _shortUrl,
                style: AppTextStyles.w500.copyWith(fontSize: 13.sp, color: colors.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
