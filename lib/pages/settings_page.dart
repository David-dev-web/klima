import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/weather_provider.dart';
import 'about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(wp.translate('SETTINGS'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _SectionHeader(wp.translate('UNIT_TEMP'), cs),
          const SizedBox(height: 12),
          _SettingGroup(
            cs: cs,
            children: [
              _SettingTile(
                title: 'Celsius (°C)',
                selected: wp.tempUnit == TempUnit.celsius,
                onTap: () => wp.setTempUnit(TempUnit.celsius),
                cs: cs,
              ),
              _SettingTile(
                title: 'Fahrenheit (°F)',
                selected: wp.tempUnit == TempUnit.fahrenheit,
                onTap: () => wp.setTempUnit(TempUnit.fahrenheit),
                cs: cs,
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 32),
          _SectionHeader(wp.translate('UNIT_WIND'), cs),
          const SizedBox(height: 12),
          _SettingGroup(
            cs: cs,
            children: [
              _SettingTile(title: 'km/h', selected: wp.windUnit == WindUnit.kmh, onTap: () => wp.setWindUnit(WindUnit.kmh), cs: cs),
              _SettingTile(title: 'm/s', selected: wp.windUnit == WindUnit.ms, onTap: () => wp.setWindUnit(WindUnit.ms), cs: cs),
              _SettingTile(title: 'mph', selected: wp.windUnit == WindUnit.mph, onTap: () => wp.setWindUnit(WindUnit.mph), cs: cs, isLast: true),
            ],
          ),
          const SizedBox(height: 32),
          _SectionHeader(wp.translate('LANGUAGE'), cs),
          const SizedBox(height: 12),
          _SettingGroup(
            cs: cs,
            children: [
              _SettingTile(title: 'Deutsch', selected: wp.lang == AppLanguage.de, onTap: () => wp.setLanguage(AppLanguage.de), cs: cs),
              _SettingTile(title: 'English', selected: wp.lang == AppLanguage.en, onTap: () => wp.setLanguage(AppLanguage.en), cs: cs, isLast: true),
            ],
          ),
          const SizedBox(height: 32),
          _SectionHeader(wp.translate('ABOUT'), cs),
          const SizedBox(height: 12),
          _SettingGroup(
            cs: cs,
            children: [
              ListTile(
                leading: Icon(Icons.info_outline_rounded, color: cs.primary),
                title: Text(wp.translate('ABOUT'), style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
              ),
            ],
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: Text(
      title.toUpperCase(),
      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2.0, color: cs.onSurface.withOpacity(0.5)),
    ),
  );
}

class _SettingGroup extends StatelessWidget {
  final List<Widget> children;
  final ColorScheme cs;
  const _SettingGroup({required this.children, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.onSurface.withOpacity(0.06), width: 1),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme cs;
  final bool isLast;

  const _SettingTile({
    required this.title,
    required this.selected,
    required this.onTap,
    required this.cs,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: selected ? Icon(Icons.check_circle_rounded, color: cs.primary) : null,
          onTap: onTap,
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: cs.onSurface.withOpacity(0.06)),
          ),
      ],
    );
  }
}
