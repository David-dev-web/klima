import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/location_service.dart';

class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int weatherCode;
  final double windSpeed;
  final int humidity;
  final double visibility;
  final double surfacePressure;
  final String timezone;

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.visibility,
    required this.surfacePressure,
    required this.timezone,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    return CurrentWeather(
      temperature: (current['temperature_2m'] as num? ?? 0.0).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num? ?? 0.0).toDouble(),
      weatherCode: (current['weathercode'] as num? ?? 0).toInt(),
      windSpeed: (current['windspeed_10m'] as num? ?? 0.0).toDouble(),
      humidity: (current['relative_humidity_2m'] as num? ?? 0).toInt(),
      visibility: (current['visibility'] as num? ?? 10000.0).toDouble(),
      surfacePressure: (current['surface_pressure'] as num? ?? 1013.25).toDouble(),
      timezone: json['timezone'] as String? ?? 'UTC',
    );
  }

  Map<String, dynamic> toJson() => {
        'temperature_2m': temperature,
        'apparent_temperature': apparentTemperature,
        'weathercode': weatherCode,
        'windspeed_10m': windSpeed,
        'relative_humidity_2m': humidity,
        'visibility': visibility,
        'surface_pressure': surfacePressure,
      };
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final double uvIndex;
  final DateTime sunrise;
  final DateTime sunset;
  final int precipitationProbability;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.precipitationProbability,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'maxTemp': maxTemp,
        'minTemp': minTemp,
        'weatherCode': weatherCode,
        'uvIndex': uvIndex,
        'sunrise': sunrise.toIso8601String(),
        'sunset': sunset.toIso8601String(),
        'precipProb': precipitationProbability,
      };

  factory DailyForecast.fromStoredJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.parse(json['date']),
      maxTemp: json['maxTemp'],
      minTemp: json['minTemp'],
      weatherCode: json['weatherCode'],
      uvIndex: json['uvIndex'],
      sunrise: DateTime.parse(json['sunrise']),
      sunset: DateTime.parse(json['sunset']),
      precipitationProbability: json['precipProb'],
    );
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final double apparentTemperature;
  final int weatherCode;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
  });

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'temp': temperature,
        'apparent': apparentTemperature,
        'code': weatherCode,
      };

  factory HourlyForecast.fromStoredJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.parse(json['time']),
      temperature: json['temp'],
      apparentTemperature: json['apparent'],
      weatherCode: json['code'],
    );
  }
}

class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;

  WeatherData({
    required this.current,
    required this.daily,
    required this.hourly,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
  });

  factory WeatherData.fromJson(
    Map<String, dynamic> json,
    String locationName,
  ) {
    final current = CurrentWeather.fromJson(json);

    // ── daily ─────────────────────────────────────────────────────────
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};
    final dates = dailyJson['time'] as List<dynamic>? ?? [];
    final maxTemps = dailyJson['temperature_2m_max'] as List<dynamic>? ?? [];
    final minTemps = dailyJson['temperature_2m_min'] as List<dynamic>? ?? [];
    final codes = dailyJson['weathercode'] as List<dynamic>? ?? [];
    final uvIndices = dailyJson['uv_index_max'] as List<dynamic>? ?? [];
    final sunrises = dailyJson['sunrise'] as List<dynamic>? ?? [];
    final sunsets = dailyJson['sunset'] as List<dynamic>? ?? [];
    final precipProbs = dailyJson['precipitation_probability_max'] as List<dynamic>? ?? [];

    final daily = List.generate(dates.length, (i) {
      return DailyForecast(
        date: DateTime.parse(dates[i] as String),
        maxTemp: (maxTemps[i] as num? ?? 0.0).toDouble(),
        minTemp: (minTemps[i] as num? ?? 0.0).toDouble(),
        weatherCode: (codes[i] as num? ?? 0).toInt(),
        uvIndex: (uvIndices[i] as num? ?? 0.0).toDouble(),
        sunrise: DateTime.parse(sunrises[i] as String? ?? dates[i] as String),
        sunset: DateTime.parse(sunsets[i] as String? ?? dates[i] as String),
        precipitationProbability: (precipProbs[i] as num? ?? 0).toInt(),
      );
    });

    // ── hourly ────────────────────────────────────────────────────────
    final hourlyJson = json['hourly'] as Map<String, dynamic>? ?? {};
    final List<HourlyForecast> hourly = [];
    final hTimes = hourlyJson['time'] as List<dynamic>? ?? [];
    final hTemps = hourlyJson['temperature_2m'] as List<dynamic>? ?? [];
    final hApparent = hourlyJson['apparent_temperature'] as List<dynamic>? ?? [];
    final hCodes = hourlyJson['weathercode'] as List<dynamic>? ?? [];

    for (int i = 0; i < hTimes.length; i++) {
      hourly.add(HourlyForecast(
        time: DateTime.parse(hTimes[i] as String),
        temperature: (hTemps[i] as num? ?? 0.0).toDouble(),
        apparentTemperature: (hApparent[i] as num? ?? 0.0).toDouble(),
        weatherCode: (hCodes[i] as num? ?? 0).toInt(),
      ));
    }

    return WeatherData(
      current: current,
      daily: daily,
      hourly: hourly,
      locationName: locationName,
      latitude: (json['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0.0).toDouble(),
      lastUpdated: DateTime.now(),
    );
  }

  String encode() {
    return jsonEncode({
      'current': current.toJson(),
      'daily': daily.map((d) => d.toJson()).toList(),
      'hourly': hourly.map((h) => h.toJson()).toList(),
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'lastUpdated': lastUpdated.toIso8601String(),
    });
  }

  static WeatherData? decode(String encoded) {
    try {
      final map = jsonDecode(encoded) as Map<String, dynamic>;
      final currentMap = map['current'] as Map<String, dynamic>? ?? {};
      
      return WeatherData(
        current: CurrentWeather(
          temperature: (currentMap['temperature_2m'] as num? ?? 0.0).toDouble(),
          apparentTemperature: (currentMap['apparent_temperature'] as num? ?? 0.0).toDouble(),
          weatherCode: (currentMap['weathercode'] as num? ?? 0).toInt(),
          windSpeed: (currentMap['windspeed_10m'] as num? ?? 0.0).toDouble(),
          humidity: (currentMap['relative_humidity_2m'] as num? ?? 0).toInt(),
          visibility: (currentMap['visibility'] as num? ?? 10000.0).toDouble(),
          surfacePressure: (currentMap['surface_pressure'] as num? ?? 1013.25).toDouble(),
          timezone: 'auto',
        ),
        daily: (map['daily'] as List? ?? []).map((d) => DailyForecast.fromStoredJson(d as Map<String, dynamic>)).toList(),
        hourly: (map['hourly'] as List? ?? []).map((h) => HourlyForecast.fromStoredJson(h as Map<String, dynamic>)).toList(),
        locationName: (map['locationName'] as String? ?? 'Berlin'),
        latitude: (map['latitude'] as num? ?? LocationService.defaultLat).toDouble(),
        longitude: (map['longitude'] as num? ?? LocationService.defaultLon).toDouble(),
        lastUpdated: DateTime.tryParse(map['lastUpdated']?.toString() ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('Decoding failed: $e');
      return null;
    }
  }
}

class GeocodingResult {
  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;

  GeocodingResult({
    required this.name,
    required this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      name: json['name'] as String? ?? 'Unknown',
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String?,
      latitude: (json['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0.0).toDouble(),
    );
  }

  String get displayName {
    // "📍 Sand am Main" format instead of "Sand a. Main, DE"
    return "📍 $name";
  }
}
