import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import 'weather_illustrations.dart';

class ForecastRow extends StatelessWidget {
  final DailyForecast forecast;
  final bool isToday;
  final VoidCallback? onTap;
  final double weekMin;
  final double weekMax;

  const ForecastRow({
    super.key,
    required this.forecast,
    this.isToday = false,
    this.onTap,
    required this.weekMin,
    required this.weekMax,
  });

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final cs = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Text(
                isToday ? wp.translate('TODAY').toUpperCase() : DateFormat('E', wp.lang == AppLanguage.en ? 'en_US' : 'de_DE').format(forecast.date).toUpperCase(),
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  color: isToday ? cs.primary : cs.onSurface,
                  fontSize: 12,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            WeatherIllustration(weatherCode: forecast.weatherCode, size: 32),
            const SizedBox(width: 16),
            Text(
              wp.formatTemp(forecast.minTemp),
              style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TempBar(
                min: forecast.minTemp,
                max: forecast.maxTemp,
                weekMin: weekMin,
                weekMax: weekMax,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 40,
              child: Text(
                wp.formatTemp(forecast.maxTemp),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TempBar extends StatelessWidget {
  final double min, max, weekMin, weekMax;
  final Color color;
  const _TempBar({required this.min, required this.max, required this.weekMin, required this.weekMax, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final range = weekMax - weekMin;
    final s = range == 0 ? 0.0 : ((min - weekMin) / range).clamp(0.0, 1.0);
    final e = range == 0 ? 1.0 : ((max - weekMin) / range).clamp(0.0, 1.0);

    return SizedBox(
      height: 4,
      child: CustomPaint(
        painter: _BarPainter(s, e, color, cs.outlineVariant.withOpacity(0.2)),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final double s, e;
  final Color c;
  final Color trackColor;
  _BarPainter(this.s, this.e, this.c, this.trackColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = trackColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    // Track
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(2)),
      paint,
    );

    // Progress
    paint.color = c;
    final startX = s * size.width;
    final width = ((e - s).clamp(0.05, 1.0) * size.width);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(startX, 0, width, size.height), const Radius.circular(2)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.s != s || old.e != e;
}
