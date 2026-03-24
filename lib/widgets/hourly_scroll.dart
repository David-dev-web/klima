import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import 'weather_icon.dart';

class HourlyScroll extends StatelessWidget {
  final List<HourlyForecast> hours;
  const HourlyScroll({super.key, required this.hours});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (hours.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hours.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final h = hours[i];
          final isNow = i == 0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 72,
            decoration: BoxDecoration(
              color: isNow ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isNow ? wp.translate('Jetzt', 'Now') : DateFormat('HH:mm').format(h.time),
                  style: textTheme.labelSmall?.copyWith(
                    color: isNow ? colorScheme.onPrimaryContainer : colorScheme.onSurface.withAlpha(153),
                    fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(WeatherIcon.getInfo(h.weatherCode).emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(
                  wp.formatTemp(h.temperature),
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: isNow ? colorScheme.onPrimaryContainer : colorScheme.onSurface),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
