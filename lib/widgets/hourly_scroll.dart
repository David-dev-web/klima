import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import 'weather_illustrations.dart';

class HourlyScroll extends StatelessWidget {
  final List<HourlyForecast> hours;
  const HourlyScroll({super.key, required this.hours});

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) return const SizedBox.shrink();

    final wp = context.watch<WeatherProvider>();
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Stack(
        children: [
          _TrendLine(hours: hours, color: cs.primary.withOpacity(0.2)),
          ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: hours.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final h = hours[i];
              final isNow = i == 0;
              final Color bgColor = isNow ? cs.primaryContainer : cs.surfaceContainerHigh;
              final Color onColor = isNow ? cs.onPrimaryContainer : cs.onSurface;

              return Container(
                width: 76,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: cs.onSurface.withOpacity(isNow ? 0.0 : 0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isNow ? wp.translate('NOW').toUpperCase() : DateFormat('HH:mm').format(h.time),
                      style: textTheme.labelSmall?.copyWith(
                        color: onColor.withOpacity(0.6),
                        fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    WeatherIllustration(weatherCode: h.weatherCode, size: 36),
                    Text(
                      wp.formatTemp(h.temperature),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: onColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TrendLine extends StatelessWidget {
  final List<HourlyForecast> hours;
  final Color color;
  const _TrendLine({required this.hours, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size(hours.length * 88.0 + 40.0, 160),
        painter: _TrendLinePainter(hours: hours, color: color),
      ),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  final List<HourlyForecast> hours;
  final Color color;
  _TrendLinePainter({required this.hours, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (hours.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double itemWidth = 88.0; // 76 width + 12 spacing
    final double startX = 20.0 + 38.0; // 20 padding + half card width
    
    final temps = hours.map((e) => e.temperature).toList();
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final range = (maxTemp - minTemp).abs() < 1 ? 1.0 : (maxTemp - minTemp);

    for (int i = 0; i < hours.length; i++) {
        final x = startX + i * itemWidth;
        // Normalize temp to y (inverted: high temp = low Y)
        final y = 110 - ((hours[i].temperature - minTemp) / range * 40);
        
        if (i == 0) {
            path.moveTo(x, y);
        } else {
            path.lineTo(x, y);
        }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrendLinePainter old) => old.hours != hours;
}

