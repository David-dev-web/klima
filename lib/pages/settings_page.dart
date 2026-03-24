import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/weather_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(wp.translate('Einstellungen', 'Settings'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SectionHeader(wp.translate('Einheiten', 'Units'), cs),
          const SizedBox(height: 16),
          _Setting(
            label: wp.translate('Temperatur', 'Temperature'),
            current: wp.tempUnit == TempUnit.celsius ? 'Celsius (°C)' : 'Fahrenheit (°F)',
            options: ['°C', '°F'],
            onSelect: (v) => wp.setTempUnit(v == '°F' ? TempUnit.fahrenheit : TempUnit.celsius),
            cs: cs,
          ),
          _Setting(
            label: wp.translate('Windgeschwindigkeit', 'Wind Speed'),
            current: wp.windUnit == WindUnit.kmh ? 'km/h' : (wp.windUnit == WindUnit.ms ? 'm/s' : 'mph'),
            options: ['km/h', 'm/s', 'mph'],
            onSelect: (v) {
              if (v == 'm/s') {
                wp.setWindUnit(WindUnit.ms);
              } else if (v == 'mph') {
                wp.setWindUnit(WindUnit.mph);
              } else {
                wp.setWindUnit(WindUnit.kmh);
              }
            },
            cs: cs,
          ),
          const SizedBox(height: 32),
          _SectionHeader(wp.translate('Sprache', 'Language'), cs),
          const SizedBox(height: 16),
          _Setting(
            label: wp.translate('App-Sprache', 'App Language'),
            current: wp.lang == AppLanguage.de ? 'Deutsch' : 'English',
            options: ['Deutsch', 'English'],
            onSelect: (v) => wp.setLanguage(v == 'English' ? AppLanguage.en : AppLanguage.de),
            cs: cs,
          ),
          const SizedBox(height: 48),
          _SectionHeader(wp.translate('Über die App', 'About'), cs),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Version', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('1.0.0+2 (Klima)'),
            trailing: Icon(Icons.info_outline_rounded, color: cs.primary),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title; final ColorScheme cs;
  const _SectionHeader(this.title, this.cs);
  @override
  Widget build(BuildContext context) => Text(title.toUpperCase(), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: cs.primary));
}

class _Setting extends StatelessWidget {
  final String label, current; final List<String> options; final Function(String) onSelect; final ColorScheme cs;
  const _Setting({required this.label, required this.current, required this.options, required this.onSelect, required this.cs});
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(current, style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
    trailing: PopupMenuButton<String>(onSelected: onSelect, itemBuilder: (_) => options.map((o) => PopupMenuItem(value: o, child: Text(o))).toList(), icon: const Icon(Icons.tune_rounded)),
  );
}
