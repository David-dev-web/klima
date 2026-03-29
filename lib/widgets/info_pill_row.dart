import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';

class InfoPillRow extends StatelessWidget {
  final WeatherData data;
  const InfoPillRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final cs = Theme.of(context).colorScheme;
    final today = data.daily.first;

    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Pill(icon: Icons.wb_sunny_rounded, label: 'UV: ${today.uvIndex.round()}', cs: cs),
          _Pill(icon: Icons.wb_twilight_rounded, label: '⬆ ${DateFormat('HH:mm').format(today.sunrise)}', cs: cs),
          _Pill(icon: Icons.nights_stay_rounded, label: '⬇ ${DateFormat('HH:mm').format(today.sunset)}', cs: cs),
          _Pill(icon: Icons.umbrella_rounded, label: '${wp.translate('RAIN')}: ${today.precipitationProbability}%', cs: cs),
          _Pill(icon: Icons.visibility_rounded, label: '${wp.translate('VISIBILITY')}: ${(data.current.visibility / 1000).toStringAsFixed(1)}km', cs: cs),
          _Pill(icon: Icons.speed_rounded, label: '${wp.translate('PRESSURE')}: ${data.current.surfacePressure.round()}hPa', cs: cs),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;
  const _Pill({required this.icon, required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: cs.outlineVariant.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
