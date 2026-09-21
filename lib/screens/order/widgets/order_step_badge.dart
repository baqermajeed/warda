import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';

/// مؤشر الخطوة الدائري (1/2 أصفر، 2/2 أخضر).
class OrderStepBadge extends StatelessWidget {
  const OrderStepBadge({
    super.key,
    required this.label,
    required this.color,
    this.progress = 1,
  });

  final String label;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: CustomPaint(
        painter: _StepRingPainter(color: color, progress: progress),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _StepRingPainter extends CustomPainter {
  _StepRingPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 1.6;
    final rect = Offset(stroke, stroke) &
        Size(size.width - stroke * 2, size.height - stroke * 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // يبدأ من أعلى اليمين كما في Figma (قوس أصفر للخطوة 1).
    final start = -math.pi / 2;
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(rect, start, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant _StepRingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.progress != progress;
}
