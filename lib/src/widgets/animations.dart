
import 'package:flutter/material.dart';
import 'dart:math';

class CloudRainAnimation extends StatefulWidget {
  final bool rain;
  final Color color;
  final double height;
  const CloudRainAnimation({super.key, this.rain = false, this.color = Colors.white54, this.height = 120});

  @override
  State<CloudRainAnimation> createState() => _CloudRainAnimationState();
}

class _CloudRainAnimationState extends State<CloudRainAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return CustomPaint(
            painter: _CloudPainter(progress: _ctrl.value, rain: widget.rain, color: widget.color),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  final double progress;
  final bool rain;
  final Color color;
  _CloudPainter({required this.progress, required this.rain, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.9);
    final w = size.width;
    final h = size.height;
    // Draw moving clouds - three ellipses that move horizontally
    final t = progress * 2 * pi;
    final offsets = [sin(t) * 20, sin(t + 1.6) * 30, sin(t + 3.1) * 18];
    final xs = [w * 0.15 + offsets[0], w * 0.45 + offsets[1], w * 0.75 + offsets[2]];
    for (int i=0;i<3;i++) {
      final cx = xs[i];
      final cy = h * (0.35 + i * 0.05);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: w * 0.36, height: h * 0.5), paint);
    }

    if (rain) {
      final dropPaint = Paint()..color = color.withOpacity(0.9)..strokeWidth = 2.0..strokeCap = StrokeCap.round;
      final rng = Random(42);
      // draw dropping lines moving with progress
      for (int c=0;c<12;c++) {
        final x = (c / 12) * w + (progress * w) % 40;
        final yStart = h * 0.55 + (rng.nextDouble() * h * 0.25);
        final length = 10.0 + rng.nextDouble() * 8.0;
        canvas.drawLine(Offset(x, yStart), Offset(x - 2, yStart + length), dropPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.rain != rain;
}
