import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(wp.translate('ABOUT')),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: Icon(Icons.wb_sunny_rounded, size: 100, color: Colors.amber),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Klima',
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'Version 1.0.0+1',
              style: TextStyle(color: cs.onSurface.withAlpha(150)),
            ),
          ),
          const SizedBox(height: 40),
          _AboutSection(
            title: wp.customTranslate('Beschreibung', 'Description'),
            content: wp.customTranslate(
              'Eine expressive Wetter-App mit Fokus auf Design und Datenschutz. Gevibecodet mit KI.',
              'An expressive weather app focused on design and privacy. Vibecoded with AI.',
            ),
          ),
          _AboutSection(
            title: wp.customTranslate('Datenquelle', 'Data Source'),
            content: 'Open-Meteo API (Free for non-commercial use)',
          ),
          _AboutSection(
            title: wp.customTranslate('Lizenz', 'License'),
            content: 'MIT License\n\nCopyright (c) 2026 David-dev-web',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Text(
            wp.customTranslate('Mitwirkende', 'Contributors'),
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text('• David-dev-web (Main Developer)\n• Antigravity AI (Coding Assistant)'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final String title;
  final String content;
  const _AboutSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(content, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(200))),
        ],
      ),
    );
  }
}
