import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';

/// Circular avatar used across search results, contacts, and request lists.
///
/// Falls back to a coral->teal gradient with initials when [avatarUrl] is
/// null — keeps every list item feeling branded even with zero real photos
/// in mock/empty states, and gives each user a distinct-ish gradient angle
/// based on their uid so a long list doesn't look like identical chips.
class PulseAvatar extends StatelessWidget {
  const PulseAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = 52,
    this.isOnline = false,
    this.seed = '',
  });

  final String name;
  final String? avatarUrl;
  final double size;
  final bool isOnline;
  final String seed;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final dim = size.r;

    // Slightly vary the gradient direction per-user using the seed so a
    // list of fallback avatars isn't visually identical.
    final hash = seed.hashCode;
    final angle = (hash % 4);
    final begin = [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.topCenter,
    ][angle.abs() % 4];
    final end = [
      Alignment.bottomRight,
      Alignment.bottomLeft,
      Alignment.topRight,
      Alignment.bottomCenter,
    ][angle.abs() % 4];

    return SizedBox(
      width: dim,
      height: dim,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(dim / 2),
            child: avatarUrl != null
                ? Image.network(
                    avatarUrl!,
                    width: dim,
                    height: dim,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _gradientFallback(colors, begin, end, dim),
                  )
                : _gradientFallback(colors, begin, end, dim),
          ),
          if (isOnline)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: (dim * 0.28).clamp(12, 18),
                height: (dim * 0.28).clamp(12, 18),
                decoration: BoxDecoration(
                  color: colors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 2.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _gradientFallback(AppColors colors, Alignment begin, Alignment end, double dim) {
    return Container(
      width: dim,
      height: dim,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [colors.primary, colors.secondary],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
          fontSize: (dim * 0.36),
        ),
      ),
    );
  }
}
