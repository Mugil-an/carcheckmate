import 'dart:math';
import 'package:flutter/material.dart';

class RiskMeter extends StatelessWidget {
  final double score; // 0..100

  const RiskMeter({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final percent = (score / 100).clamp(0.0, 1.0);

    // Theme-based colors
    final Color safeColor = Colors.blue; // base theme color
    final Color mediumColor = Colors.orange.shade400;
    final Color dangerColor = Colors.red.shade400;

    Color color;
    if (score >= 66) {
      color = dangerColor;
    } else if (score >= 33) {
      color = mediumColor;
    } else {
      color = safeColor;
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.blue.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Vehicle Risk',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _RiskMeterPainter(
                  percentage: percent,
                  color: color,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${score.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 34,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _riskLabel(score),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _riskLabel(double score) {
    if (score >= 66) return "High Risk";
    if (score >= 33) return "Medium Risk";
    return "Low Risk";
  }
}

class _RiskMeterPainter extends CustomPainter {
  final double percentage;
  final Color color;

  _RiskMeterPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 14.0;
    const startAngle = -pi / 2;
    const sweepAngle = 2 * pi;

    // Background arc (light blue/grey)
    final backgroundPaint = Paint()
      ..color = Colors.blue.shade50
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Foreground arc
    final foregroundPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withOpacity(0.8), color],
        startAngle: startAngle,
        endAngle: startAngle + (sweepAngle * percentage),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * percentage,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
