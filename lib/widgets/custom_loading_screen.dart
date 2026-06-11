import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/google_fonts.dart';

class CustomLoadingScreen extends StatefulWidget {
  const CustomLoadingScreen({super.key});

  @override
  State<CustomLoadingScreen> createState() => _CustomLoadingScreenState();
}

class _CustomLoadingScreenState extends State<CustomLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom pulsing ripple animation
            SizedBox(
              width: 200,
              height: 200,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _RipplePainter(
                      progress: _controller.value,
                      color: cs.onSurface,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Minimal branding
            Text(
              kAppName,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            // Breathing loading text
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Smooth breathing opacity using cosine curve
                final double opacity = 0.35 + 0.45 * (0.5 - 0.5 * cos(_controller.value * 2 * pi));
                return Opacity(
                  opacity: opacity,
                  child: Text(
                    'gathering shelf…',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _RipplePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final center = Offset(centerX, centerY);

    final basePaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    // Draw central dot
    canvas.drawCircle(center, 4, basePaint..color = color.withValues(alpha: 0.5));

    // Three waves of ripples
    for (int i = 0; i < 3; i++) {
      // Offset progress for waves: wave 0 (progress), wave 1 (+0.33), wave 2 (+0.67)
      final double waveProgress = (progress + (i * 0.33)) % 1.0;

      // Outer rings expand from radius 20 to 85
      final double radius = 20 + waveProgress * 65;

      // Opacity fades out as it expands
      final double opacity = (1.0 - waveProgress) * 0.25;

      final wavePaint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawCircle(center, radius, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return progress != oldDelegate.progress || color != oldDelegate.color;
  }
}
