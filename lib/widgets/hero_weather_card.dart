import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import 'weather_icon.dart';
import 'weather_illustrations.dart';

class HeroWeatherCard extends StatefulWidget {
  final WeatherData data;
  const HeroWeatherCard({super.key, required this.data});

  @override
  State<HeroWeatherCard> createState() => _HeroWeatherCardState();
}

class _HeroWeatherCardState extends State<HeroWeatherCard> with TickerProviderStateMixin {
  late AnimationController _windController;
  late AnimationController _rainController;

  @override
  void initState() {
    super.initState();
    _windController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _rainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _windController.dispose();
    _rainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final cs = Theme.of(context).colorScheme;
    final isRainy = widget.data.current.weatherCode >= 51 && widget.data.current.weatherCode <= 67;
    final isWindy = widget.data.current.windSpeed > 20;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: _getDynamicGradient(widget.data, cs),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                ),
                child: Column(
                  children: [
                    Hero(
                      tag: 'weather_icon',
                      child: WeatherIllustration(weatherCode: widget.data.current.weatherCode, size: 100),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      wp.formatTemp(widget.data.current.temperature),
                      style: GoogleFonts.outfit(fontSize: 100, fontWeight: FontWeight.w100, color: Colors.white, height: 1.0),
                    ),
                    Text(
                      '${wp.translate('FEELS_LIKE')} ${wp.formatTemp(widget.data.current.apparentTemperature)}',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w300, color: Colors.white70, letterSpacing: 1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      WeatherIcon.getInfo(widget.data.current.weatherCode).description,
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w400, color: Colors.white, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatItem(label: wp.translate('WIND'), value: wp.formatWind(widget.data.current.windSpeed)),
                        _Dot(),
                        _StatItem(label: wp.translate('HUMIDITY'), value: '${widget.data.current.humidity}%'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isRainy) Positioned.fill(child: _RainOverlay(controller: _rainController)),
            if (isWindy) Positioned.fill(child: _WindOverlay(controller: _windController)),
          ],
        ),
      ),
    );
  }

  LinearGradient _getDynamicGradient(WeatherData data, ColorScheme cs) {
    if (data.daily.isEmpty) return LinearGradient(colors: [cs.primary, cs.secondary, cs.tertiary]);

    final now = DateTime.now();
    final today = data.daily.first;
    final isNight = now.isAfter(today.sunset) || now.isBefore(today.sunrise);
    final code = data.current.weatherCode;

    if (isNight) {
      if (code <= 1) return const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF312E81), Color(0xFF1E1B4B), Colors.black], begin: Alignment.topLeft, end: Alignment.bottomRight, stops: [0.0, 0.3, 0.7, 1.0]);
      return const LinearGradient(colors: [Color(0xFF374151), Color(0xFF1F2937), Color(0xFF111827), Colors.black], begin: Alignment.topLeft, end: Alignment.bottomRight, stops: [0.0, 0.3, 0.7, 1.0]);
    }

    if (code <= 1) return const LinearGradient(colors: [Color(0xFFFFB700), Color(0xFFFF8C00), Color(0xFFE85D04), Color(0xFFDC2F02)], begin: Alignment.topLeft, end: Alignment.bottomRight, stops: [0.0, 0.3, 0.7, 1.0]);
    if (code <= 3) return const LinearGradient(colors: [Color(0xFF94A3B8), Color(0xFF64748B), Color(0xFF475569), Color(0xFF334155)], begin: Alignment.topLeft, end: Alignment.bottomRight, stops: [0.0, 0.3, 0.7, 1.0]);
    if (code <= 69) return const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E40AF)], begin: Alignment.topLeft, end: Alignment.bottomRight, stops: [0.0, 0.3, 0.7, 1.0]);
    
    return LinearGradient(colors: [cs.primary, cs.secondary, cs.primaryContainer, cs.surfaceVariant], begin: Alignment.topLeft, end: Alignment.bottomRight, stops: const [0.0, 0.3, 0.7, 1.0]);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w400,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    width: 4, height: 4,
    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
  );
}

class _RainOverlay extends StatelessWidget {
  final AnimationController controller;
  const _RainOverlay({required this.controller});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => CustomPaint(painter: _RainPainter(progress: controller.value)),
  );
}

class _RainPainter extends CustomPainter {
  final double progress;
  _RainPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.2)..strokeWidth = 1.2..strokeCap = StrokeCap.round;
    final rand = math.Random(42);
    for (int i = 0; i < 40; i++) {
        final x = rand.nextDouble() * size.width;
        final startY = (rand.nextDouble() + progress) % 1.0 * size.height;
        canvas.drawLine(Offset(x, startY), Offset(x - 1, startY + 12), paint);
    }
  }
  @override
  bool shouldRepaint(_RainPainter old) => true;
}

class _WindOverlay extends StatelessWidget {
  final AnimationController controller;
  const _WindOverlay({required this.controller});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => CustomPaint(painter: _WindPainter(progress: controller.value)),
  );
}

class _WindPainter extends CustomPainter {
  final double progress;
  _WindPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    for (int i = 0; i < 6; i++) {
        final y = 30.0 + i * 60;
        final xStart = (progress * size.width * 2 + i * 120) % (size.width + 300) - 150;
        final path = Path()..moveTo(xStart, y)..quadraticBezierTo(xStart + 60, y - 15, xStart + 120, y);
        canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(_WindPainter old) => true;
}
