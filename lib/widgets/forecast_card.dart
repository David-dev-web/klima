import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import 'weather_icon.dart';

class ForecastRow extends StatelessWidget {
  final DailyForecast forecast;
  final bool isToday;
  final VoidCallback? onTap;

  const ForecastRow({super.key, required this.forecast, this.isToday = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final cs = Theme.of(context).colorScheme;
    final info = WeatherIcon.getInfo(forecast.weatherCode);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                isToday ? wp.translate('TODAY') : DateFormat('E', wp.lang == AppLanguage.en ? 'en_US' : 'de_DE').format(forecast.date),
                style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.w500, color: isToday ? cs.primary : cs.onSurface),
              ),
            ),
            Text(info.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                info.description,
                style: TextStyle(color: cs.onSurface.withAlpha(178)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                Text(wp.formatTemp(forecast.minTemp), style: TextStyle(color: cs.onSurface.withAlpha(128))),
                const SizedBox(width: 8),
                _TempBar(min: forecast.minTemp, max: forecast.maxTemp, color: isToday ? cs.primary : cs.secondary),
                const SizedBox(width: 8),
                SizedBox(
                  width: 44,
                  child: Text(wp.formatTemp(forecast.maxTemp), style: TextStyle(fontWeight: FontWeight.bold, color: isToday ? cs.primary : cs.onSurface), textAlign: TextAlign.right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TempBar extends StatelessWidget {
  final double min, max;
  final Color color;
  const _TempBar({required this.min, required this.max, required this.color});
  @override
  Widget build(BuildContext context) {
    final range = 55.0; // Assume -10 to 45
    final s = ((min + 10) / range).clamp(0.0, 1.0);
    final e = ((max + 10) / range).clamp(0.0, 1.0);
    return SizedBox(width: 48, height: 4, child: CustomPaint(painter: _BarPainter(s, e, color, Theme.of(context).colorScheme.outlineVariant.withAlpha(100))));
  }
}

class _BarPainter extends CustomPainter {
  final double s, e; final Color c, tc;
  _BarPainter(this.s, this.e, this.c, this.tc);
  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(size.height / 2);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0,0,size.width,size.height), r), Paint()..color=tc);
    if (e > s) canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s*size.width,0,(e-s)*size.width,size.height),r), Paint()..color=c);
  }
  @override
  bool shouldRepaint(_BarPainter old) => old.s!=s||old.e!=e||old.c!=c;
}
