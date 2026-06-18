import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_chat/config/routes/app_routes.dart';
import 'package:pulse_chat/features/authentication/bloc/auth_bloc.dart';
import 'package:pulse_chat/features/authentication/bloc/auth_event.dart';
import 'package:pulse_chat/features/authentication/bloc/auth_state.dart';
import 'package:pulse_chat/features/authentication/widgets/auth_background.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> with SingleTickerProviderStateMixin {
  late final AnimationController _heartbeatController;

  @override
  void initState() {
    super.initState();
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<AuthBloc>().add(const AuthCheckRequested());
      await _openLoginAfterDelay();
    });
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    super.dispose();
  }

  Future<void> _openLoginAfterDelay() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;
    context.go(
      authState is Authenticated ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: AuthBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    color: colorScheme.onPrimary,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Pulse Chat',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect in a heartbeat',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 128,
                  height: 34,
                  child: AnimatedBuilder(
                    animation: _heartbeatController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _HeartbeatPainter(
                          color: colorScheme.onPrimary,
                          progress: _heartbeatController.value,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeartbeatPainter extends CustomPainter {
  const _HeartbeatPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      Offset(0, size.height * 0.58),
      Offset(size.width * 0.18, size.height * 0.58),
      Offset(size.width * 0.26, size.height * 0.58),
      Offset(size.width * 0.32, size.height * 0.25),
      Offset(size.width * 0.40, size.height * 0.82),
      Offset(size.width * 0.48, size.height * 0.12),
      Offset(size.width * 0.58, size.height * 0.58),
      Offset(size.width * 0.76, size.height * 0.58),
      Offset(size.width, size.height * 0.58),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    final basePaint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, basePaint);

    final metric = path.computeMetrics().first;
    final head = metric.length * progress;
    final tail = (head - metric.length * 0.42).clamp(0.0, metric.length);
    final activePath = metric.extractPath(tail, head);

    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(activePath, activePaint);
  }

  @override
  bool shouldRepaint(covariant _HeartbeatPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
