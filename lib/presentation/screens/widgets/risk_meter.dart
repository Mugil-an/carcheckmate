import 'dart:math';
import 'package:flutter/material.dart';

enum RiskLevel { low, medium, high }

RiskLevel riskLevelFromScore(double score) {
  if (score <= 30) return RiskLevel.low;
  if (score <= 70) return RiskLevel.medium;
  return RiskLevel.high;
}

typedef RiskInfo = ({Color color, String label});

/// Animated RiskMeter that matches the visual style from assets/images.
class RiskMeter extends StatefulWidget {
  final double score; // 0..100
  final double size; // width/height

  const RiskMeter({super.key, required this.score, this.size = 200});

  @override
  State<RiskMeter> createState() => _RiskMeterState();
}

class _RiskMeterState extends State<RiskMeter> {
  @override
  Widget build(BuildContext context) {
    // Default to 0.0 (no risk) when score is invalid
    final score = widget.score.isNaN ? 0.0 : widget.score.clamp(0.0, 100.0);
    final percent = (score / 100).clamp(0.0, 1.0);
    final riskInfo = _getRiskInfo(score);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // optional logo above title (images/carcheckmate_logo.png)
        SizedBox(
          height: 36,
          child: Image.asset(
            'assets/images/carcheckmate_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Vehicle Risk Score',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(220),
          ),
        ),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: percent),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, animatedPercent, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _RiskMeterPainter(
                      percentage: animatedPercent,
                      color: riskInfo.color,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${score.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: widget.size * 0.22,
                          fontWeight: FontWeight.w800,
                          color: riskInfo.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        riskInfo.label,
                        style: TextStyle(
                          fontSize: widget.size * 0.07,
                          fontWeight: FontWeight.w600,
                          color: riskInfo.color.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  RiskInfo _getRiskInfo(double score) {
    final level = riskLevelFromScore(score);
    switch (level) {
      case RiskLevel.low:
        return (color: const Color(0xFF27AE60), label: 'Low Risk');
      case RiskLevel.medium:
        return (color: const Color(0xFFFFB300), label: 'Medium Risk');
      case RiskLevel.high:
        return (color: const Color(0xFFE53935), label: 'High Risk');
    }
  }
}

class _RiskMeterPainter extends CustomPainter {
  final double percentage; // 0..1
  final Color color;

  _RiskMeterPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 16;
    final strokeWidth = size.width * 0.075; // scale with size
    const startAngle = -pi / 2;
    const fullSweep = 2 * pi;

    // Draw faint background ring (glass feel)
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Segmented subtle bands
    final segments = <Map<String, Object>>[
      {'color': const Color(0xFFE53935), 'stop': 0.49},
      {'color': const Color(0xFFFFA000), 'stop': 0.79},
      {'color': const Color(0xFF27AE60), 'stop': 1.0},
    ];

    double last = 0.0;
    for (final seg in segments) {
      final segStop = (seg['stop']! as double).clamp(0.0, 1.0);
      final sweep = fullSweep * (segStop - last);
      final segPaint = Paint()
        ..color = (seg['color']! as Color).withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle + fullSweep * last, sweep, false, segPaint);
      last = segStop;
    }

    // Foreground gradient sweep
    if (percentage > 0.0001) {
      final sweep = fullSweep * percentage;

      final shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweep,
        colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      final fgPaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, false, fgPaint);

      // glow
      final glowPaint = Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, false, glowPaint);

      // knob
      final endAngle = startAngle + sweep;
      final knob = Offset(cos(endAngle), sin(endAngle)) * radius + center;
      canvas.drawCircle(knob.translate(0, 1.6), strokeWidth * 0.45 + 1.6, Paint()..color = Colors.black.withOpacity(0.12));
      canvas.drawCircle(knob, strokeWidth * 0.45, Paint()..color = color);
    }

    // small center inner ring for depth
    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, radius * 0.6, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _RiskMeterPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}

