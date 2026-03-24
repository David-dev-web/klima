import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';

enum TempUnit { celsius, fahrenheit }
enum WindUnit { kmh, ms, mph }
enum AppLanguage { de, en }

class WeatherProvider extends ChangeNotifier {
  final _service = WeatherService();
  final _location = LocationService();

  WeatherData? _data;
  bool _loading = false;
  String? _error;

  TempUnit _tempUnit = TempUnit.celsius;
  WindUnit _windUnit = WindUnit.kmh;
  AppLanguage _lang = AppLanguage.de;

  WeatherData? get data => _data;
  bool get isLoading => _loading;
  String? get error => _error;
  TempUnit get tempUnit => _tempUnit;
  WindUnit get windUnit => _windUnit;
  AppLanguage get lang => _lang;

  WeatherProvider() {
    _loadSettings();
    _initApp();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _tempUnit = (prefs.getString('temp_unit') == '°F') ? TempUnit.fahrenheit : TempUnit.celsius;
    
    final w = prefs.getString('wind_unit');
    if (w == 'm/s') {
      _windUnit = WindUnit.ms;
    } else if (w == 'mph') {
      _windUnit = WindUnit.mph;
    } else {
      _windUnit = WindUnit.kmh;
    }

    _lang = (prefs.getString('lang') == 'English') ? AppLanguage.en : AppLanguage.de;
    notifyListeners();
  }

  Future<void> setTempUnit(TempUnit unit) async {
    _tempUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temp_unit', unit == TempUnit.fahrenheit ? '°F' : '°C');
    notifyListeners();
  }

  Future<void> setWindUnit(WindUnit unit) async {
    _windUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    String val = 'km/h';
    if (unit == WindUnit.ms) val = 'm/s';
    if (unit == WindUnit.mph) val = 'mph';
    await prefs.setString('wind_unit', val);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage l) async {
    _lang = l;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', l == AppLanguage.en ? 'English' : 'Deutsch');
    notifyListeners();
  }

  Future<void> _initApp() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_weather');
    if (cached != null) {
      _data = WeatherData.decode(cached);
      notifyListeners();
    }
    await refreshWeather();
  }

  Future<void> refreshWeather() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final pos = await _location.getCurrentPosition();
      final name = await _service.reverseGeocode(pos.latitude, pos.longitude);
      final formattedName = name.startsWith('📍') ? name : '📍 $name';
      
      _data = await _service.fetchWeather(latitude: pos.latitude, longitude: pos.longitude, locationName: formattedName);
      _loading = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_weather', _data!.encode());
    } catch (e) {
      debugPrint('Refetch failed ($e). Falling back to Berlin/Cache.');
      if (_data == null) {
        try {
           _data = await _service.fetchWeather(latitude: LocationService.defaultLat, longitude: LocationService.defaultLon, locationName: '📍 Berlin');
        } catch (_) {
          _error = 'Laden fehlgeschlagen.';
        }
      }
      _loading = false;
    }
    notifyListeners();
  }

  Future<void> loadLocation(double lat, double lon, String name) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _service.fetchWeather(latitude: lat, longitude: lon, locationName: name);
      _loading = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_weather', _data!.encode());
    } catch (e) {
      _loading = false;
      _error = 'Fehler: $e';
    }
    notifyListeners();
  }

  // Conversion Helpers
  String formatTemp(double celsius) {
    if (_tempUnit == TempUnit.fahrenheit) {
      return '${(celsius * 9 / 5 + 32).round()}°F';
    }
    return '${celsius.round()}°C';
  }

  String formatWind(double kmh) {
    if (_windUnit == WindUnit.ms) return '${(kmh / 3.6).toStringAsFixed(1)} m/s';
    if (_windUnit == WindUnit.mph) return '${(kmh / 1.609).round()} mph';
    return '${kmh.round()} km/h';
  }

  String translate(String de, String en) => _lang == AppLanguage.de ? de : en;
}
