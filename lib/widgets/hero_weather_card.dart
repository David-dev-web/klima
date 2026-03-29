import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import 'weather_icon.dart';
import 'dart:math' as math;

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
    final colorScheme = Theme.of(context).colorScheme;
    final info = WeatherIcon.getInfo(widget.data.current.weatherCode);
    final isRainy = widget.data.current.weatherCode >= 51 && widget.data.current.weatherCode <= 67;
    final isWindy = widget.data.current.windSpeed > 20;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(48),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: _getDynamicGradient(widget.data, colorScheme),
                boxShadow: [BoxShadow(color: colorScheme.primary.withAlpha(30), blurRadius: 30, offset: const Offset(0, 15))],
              ),
              child: Column(
                children: [
                  Hero(tag: 'weather_icon', child: WeatherIcon(code: widget.data.current.weatherCode, size: 80, animated: true)),
                  const SizedBox(height: 8),
                  Text(
                    wp.formatTemp(widget.data.current.temperature),
                    style: GoogleFonts.outfit(fontSize: 96, fontWeight: FontWeight.w200, color: Colors.white, height: 1),
                  ),
                  Text(
                    '${wp.translate('FEELS_LIKE')} ${wp.formatTemp(widget.data.current.apparentTemperature)}',
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    info.description,
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w400, color: Colors.white.withAlpha(200)),
                  ),
                  const SizedBox(height: 24),
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
            if (isRainy) Positioned.fill(child: _RainOverlay(controller: _rainController)),
            if (isWindy) Positioned.fill(child: _WindOverlay(controller: _windController)),
          ],
        ),
      ),
    );
  }

  LinearGradient _getDynamicGradient(WeatherData data, ColorScheme colorScheme) {
    if (data.daily.isEmpty) return LinearGradient(colors: [colorScheme.primary, colorScheme.secondary]);

    final now = DateTime.now();
    final today = data.daily.first;
    final isNight = now.isAfter(today.sunset) || now.isBefore(today.sunrise);
    final code = data.current.weatherCode;

    if (isNight) {
      if (code <= 1) return const LinearGradient(colors: [Colors.indigo, Color(0xFF4A148C)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      return LinearGradient(colors: [Colors.blueGrey.shade900, Colors.black87], begin: Alignment.topLeft, end: Alignment.bottomRight);
    }

    if (code <= 1) return const LinearGradient(colors: [Colors.amber, Colors.orange], begin: Alignment.topLeft, end: Alignment.bottomRight);
    if (code <= 3) return LinearGradient(colors: [Colors.blueGrey.shade300, Colors.grey.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight);
    if (code <= 69) return const LinearGradient(colors: [Colors.blue, Colors.teal], begin: Alignment.topLeft, end: Alignment.bottomRight);
    if (code <= 79) return const LinearGradient(colors: [Colors.lightBlue, Colors.white70], begin: Alignment.topLeft, end: Alignment.bottomRight);

    return LinearGradient(colors: [colorScheme.primary, colorScheme.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))]);
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.symmetric(horizontal: 16), width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white38, shape: BoxShape.circle));
}

class _RainOverlay extends StatelessWidget {
  final AnimationController controller;
  const _RainOverlay({required this.controller});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: controller, builder: (context, _) => CustomPaint(painter: _RainPainter(progress: controller.value)));
}

class _RainPainter extends CustomPainter {
  final double progress;
  _RainPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(80)..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    final rand = math.Random(42);
    for (int i = 0; i < 30; i++) {
        final x = rand.nextDouble() * size.width;
        final startY = (rand.nextDouble() + progress) % 1.0 * size.height;
        canvas.drawLine(Offset(x, startY), Offset(x - 2, startY + 10), paint);
    }
  }
  @override
  bool shouldRepaint(_RainPainter old) => true;
}

class _WindOverlay extends StatelessWidget {
  final AnimationController controller;
  const _WindOverlay({required this.controller});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: controller, builder: (context, _) => CustomPaint(painter: _WindPainter(progress: controller.value)));
}

class _WindPainter extends CustomPainter {
  final double progress;
  _WindPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(40)..style = PaintingStyle.stroke..strokeWidth = 2;
    for (int i = 0; i < 5; i++) {
        final y = 40.0 + i * 50;
        final xStart = (progress * size.width * 2 + i * 100) % (size.width + 200) - 100;
        final path = Path()..moveTo(xStart, y)..quadraticBezierTo(xStart + 50, y - 20, xStart + 100, y);
        canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(_WindPainter old) => true;
}
