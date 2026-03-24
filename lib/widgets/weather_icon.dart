import 'package:flutter/material.dart';

/// Maps WMO weather interpretation codes to emoji + German description.
class WeatherIcon extends StatelessWidget {
  final int code;
  final double size;
  final bool animated;

  const WeatherIcon({
    super.key,
    required this.code,
    this.size = 64,
    this.animated = false,
  });

  static WeatherInfo getInfo(int code) {
    if (code == 0) {
      return const WeatherInfo('☀️', 'Klarer Himmel');
    }
    if (code == 1) {
      return const WeatherInfo('🌤️', 'Überwiegend klar');
    }
    if (code == 2) {
      return const WeatherInfo('⛅', 'Teilweise bewölkt');
    }
    if (code == 3) {
      return const WeatherInfo('☁️', 'Bedeckt');
    }
    if (code == 45 || code == 48) {
      return const WeatherInfo('🌫️', 'Neblig');
    }
    if (code >= 51 && code <= 55) {
      return const WeatherInfo('🌦️', 'Nieselregen');
    }
    if (code == 56 || code == 57) {
      return const WeatherInfo('🌧️', 'Gefrierender Nieselregen');
    }
    if (code >= 61 && code <= 65) {
      return const WeatherInfo('🌧️', 'Regen');
    }
    if (code == 66 || code == 67) {
      return const WeatherInfo('🌨️', 'Gefrierender Regen');
    }
    if (code >= 71 && code <= 77) {
      return const WeatherInfo('❄️', 'Schnee');
    }
    if (code >= 80 && code <= 82) {
      return const WeatherInfo('🌦️', 'Regenschauer');
    }
    if (code == 85 || code == 86) {
      return const WeatherInfo('🌨️', 'Schneeschauer');
    }
    if (code == 95) {
      return const WeatherInfo('⛈️', 'Gewitter');
    }
    if (code == 96 || code == 99) {
      return const WeatherInfo('⛈️', 'Gewitter mit Hagel');
    }
    return const WeatherInfo('🌡️', 'Unbekannt');
  }

  @override
  Widget build(BuildContext context) {
    final info = getInfo(code);
    if (animated) {
      return _AnimatedWeatherIcon(emoji: info.emoji, size: size);
    }
    return Text(info.emoji, style: TextStyle(fontSize: size));
  }
}

class WeatherInfo {
  final String emoji;
  final String description;
  const WeatherInfo(this.emoji, this.description);
}

class _AnimatedWeatherIcon extends StatefulWidget {
  final String emoji;
  final double size;
  const _AnimatedWeatherIcon({required this.emoji, required this.size});

  @override
  State<_AnimatedWeatherIcon> createState() => _AnimatedWeatherIconState();
}

class _AnimatedWeatherIconState extends State<_AnimatedWeatherIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotateAnim = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.rotate(
        angle: _rotateAnim.value,
        child: Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
      ),
      child: Text(widget.emoji, style: TextStyle(fontSize: widget.size)),
    );
  }
}
