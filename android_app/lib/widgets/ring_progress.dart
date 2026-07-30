import 'package:flutter/material.dart';

import '../theme/theme.dart';

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.isDark,
    required this.gradient,
    required this.lineWidth,
  });

  final double progress;
  final bool isDark;
  final Gradient gradient;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - lineWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = WwColors.darkAccent(isDark).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * 3.14159265, false, backgroundPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -3.14159265 / 2;
      final sweepAngle = 2 * 3.14159265 * progress;
      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.lineWidth != lineWidth;
  }
}

/// Poort van `RingProgressView`: grote ring met titel/waarde/doel eronder.
class RingProgress extends StatelessWidget {
  const RingProgress({
    super.key,
    required this.isDark,
    required this.current,
    required this.target,
    required this.unit,
    required this.gradient,
    this.title = '',
    this.lineWidth = 14,
    this.showLabels = true,
  });

  final bool isDark;
  final double current;
  final double target;
  final String unit;
  final Gradient gradient;
  final String title;
  final double lineWidth;
  final bool showLabels;

  double get _progress => target > 0 ? (current / target).clamp(0, 1) : 0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: ${current.roundedInt} van ${target.roundedInt} $unit',
      child: AspectRatio(
        aspectRatio: 1,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _progress),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, animatedProgress, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  painter: _RingPainter(
                    progress: animatedProgress,
                    isDark: isDark,
                    gradient: gradient,
                    lineWidth: lineWidth,
                  ),
                  size: Size.infinite,
                ),
                if (showLabels)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title.isNotEmpty)
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            color: WwColors.darkAccent(isDark).withValues(alpha: 0.5),
                          ),
                        ),
                      Text(
                        '${current.roundedInt}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: WwColors.darkAccent(isDark),
                        ),
                      ),
                      Text(
                        '/ ${target.roundedInt} $unit',
                        style: TextStyle(
                          fontSize: 11,
                          color: WwColors.darkAccent(isDark).withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Poort van `CompactRingView`: kleine ring voor de macro-rij.
class CompactRing extends StatelessWidget {
  const CompactRing({
    super.key,
    required this.isDark,
    required this.title,
    required this.current,
    required this.target,
    required this.unit,
    required this.gradient,
    this.lineWidth = 8,
  });

  final bool isDark;
  final String title;
  final double current;
  final double target;
  final String unit;
  final Gradient gradient;
  final double lineWidth;

  double get _progress => target > 0 ? (current / target).clamp(0, 1) : 0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: ${current.roundedInt} van ${target.roundedInt} $unit',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      painter: _RingPainter(
                        progress: animatedProgress,
                        isDark: isDark,
                        gradient: gradient,
                        lineWidth: lineWidth,
                      ),
                      size: Size.infinite,
                    ),
                    Text(
                      '${current.roundedInt}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: WwColors.darkAccent(isDark),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: WwColors.darkAccent(isDark).withValues(alpha: 0.6)),
          ),
          Text(
            '${target.roundedInt}$unit',
            style: TextStyle(fontSize: 11, color: WwColors.darkAccent(isDark).withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}
