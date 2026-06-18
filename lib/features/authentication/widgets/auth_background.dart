import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';

/// Signature visual for the auth flow: two soft, overlapping "chat bubble"
/// blobs in the primary (coral) and secondary (teal) brand colors, drifting
/// slowly past each other behind the form. Reads as "conversation" without
/// using a literal chat-bubble icon, and gives the screen a single bold,
/// branded moment instead of a generic gradient header.
class AuthBackground extends StatefulWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Container(
      color: colors.background,
      child: Stack(
        children: [
          // Coral blob — upper right, drifts in a slow loose ellipse.
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value * 2 * math.pi;
              return Positioned(
                top: -120.h + math.sin(t) * 14.h,
                right: -90.w + math.cos(t) * 10.w,
                child: _Blob(
                  size: 320.r,
                  color: colors.primary.withValues(alpha: colors.isDarkMode ? 0.30 : 0.85),
                ),
              );
            },
          ),
          // Teal blob — lower left, opposite phase so they breathe against
          // each other rather than moving in lockstep.
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value * 2 * math.pi;
              return Positioned(
                bottom: -100.h + math.cos(t) * 12.h,
                left: -80.w + math.sin(t) * 10.w,
                child: _Blob(
                  size: 280.r,
                  color: colors.secondary.withValues(alpha: colors.isDarkMode ? 0.26 : 0.55),
                ),
              );
            },
          ),
          // Soft blur/scrim so blobs stay atmospheric, not distracting,
          // and the form on top always has enough contrast.
          BackdropFilter(
            filter: ColorFilter.mode(Colors.transparent, BlendMode.dst),
            child: Container(color: Colors.transparent),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BlobClipper(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

/// An organic, rounded-asymmetric blob path (not a perfect circle) so the
/// shape reads as "soft speech bubble" rather than "stock gradient orb."
class _BlobClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(w * 0.50, 0);
    path.cubicTo(w * 0.85, 0, w, h * 0.20, w, h * 0.50);
    path.cubicTo(w, h * 0.78, w * 0.80, h, w * 0.48, h);
    path.cubicTo(w * 0.18, h, 0, h * 0.80, 0, h * 0.50);
    path.cubicTo(0, h * 0.22, w * 0.16, 0, w * 0.50, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
