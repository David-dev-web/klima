import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _reverseGeocodeUrl =
      'https://nominatim.openstreetmap.org/reverse';

  Future<WeatherData> fetchWeather({
    required double latitude,
    required double longitude,
    String locationName = 'Mein Standort',
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,apparent_temperature,weathercode,windspeed_10m,relative_humidity_2m,visibility,surface_pressure',
      'hourly': 'temperature_2m,apparent_temperature,weathercode',
      'daily': 'temperature_2m_max,temperature_2m_min,weathercode,uv_index_max,sunrise,sunset,precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Wetterdaten konnten nicht geladen werden: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherData.fromJson(json, locationName);
  }

  Future<List<GeocodingResult>> searchCity(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_geocodingUrl).replace(queryParameters: {
      'name': query.trim(),
      'count': '10',
      'language': 'de',
      'format': 'json',
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Geocoding fehlgeschlagen: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>?;
    if (results == null) return [];

    return results
        .map((r) => GeocodingResult.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<String> reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse(_reverseGeocodeUrl).replace(queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'format': 'json',
        'accept-language': 'de',
      });

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'WeatherApp/1.0'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final address = json['address'] as Map<String, dynamic>?;
        if (address != null) {
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['county'];
          final country = address['country_code']?.toString().toUpperCase();
          if (city != null) {
            return country != null ? '$city, $country' : city.toString();
          }
        }
        return json['display_name']?.toString().split(',').first ??
            'Mein Standort';
      }
    } catch (_) {}
    return 'Mein Standort';
  }
}
