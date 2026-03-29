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
  bool _loading = true;
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

  Future<void> refreshWeather({bool force = false}) async {
    // Caching logic: Skip if last update was < 5 minutes ago
    if (!force && _data != null && DateTime.now().difference(_data!.lastUpdated).inMinutes < 5) {
      debugPrint('Skipping refetch - data is fresh enough (< 5 min).');
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final pos = await _location.getCurrentPosition();
      final name = await _service.reverseGeocode(pos.latitude, pos.longitude);
      final formattedName = name.startsWith('📍') ? name : '📍 $name';
      
      final fetchedData = await _service.fetchWeather(
        latitude: pos.latitude, 
        longitude: pos.longitude, 
        locationName: formattedName
      );
      
      _data = fetchedData;
      _loading = false;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_weather', _data!.encode());
    } catch (e) {
      debugPrint('Refetch failed ($e). Falling back to Berlin/Cache.');
      _loading = false;
      
      if (_data == null) {
        try {
           final fallbackData = await _service.fetchWeather(
             latitude: LocationService.defaultLat, 
             longitude: LocationService.defaultLon, 
             locationName: '📍 ${LocationService.defaultName}'
           );
           _data = fallbackData;
        } catch (inner) {
          _error = translate('OFFLINE_MSG');
        }
      } else {
        // We have cached data, maybe notify user via a message?
        _error = null; // Don't show full error screen if we have some data
      }
    }
    notifyListeners();
  }

  Future<void> loadLocation(double lat, double lon, String name) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final fetchedData = await _service.fetchWeather(latitude: lat, longitude: lon, locationName: name);
      _data = fetchedData;
      _loading = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_weather', _data!.encode());
    } catch (e) {
      _loading = false;
      _error = '${translate('LOAD_ERROR')} $name';
    }
    notifyListeners();
  }

  // L10n Helper
  static const Map<String, Map<AppLanguage, String>> _texts = {
    'LOADING': {AppLanguage.de: 'Lade...', AppLanguage.en: 'Loading...'},
    'HOURLY': {AppLanguage.de: 'STÜNDLICH', AppLanguage.en: 'HOURLY'},
    'DAILY': {AppLanguage.de: '7-TAGE-VORHERSAGE', AppLanguage.en: '7-DAY FORECAST'},
    'OFFLINE_MSG': {AppLanguage.de: 'Laden fehlgeschlagen. Bitte Internetverbindung prüfen.', AppLanguage.en: 'Loading failed. Please check your internet connection.'},
    'LOAD_ERROR': {AppLanguage.de: 'Fehler beim Laden von', AppLanguage.en: 'Error loading'},
    'RETRY': {AppLanguage.de: 'Erneut versuchen', AppLanguage.en: 'Retry'},
    'ABOUT': {AppLanguage.de: 'Über Klima', AppLanguage.en: 'About Klima'},
    'SETTINGS': {AppLanguage.de: 'Einstellungen', AppLanguage.en: 'Settings'},
    'FEELS_LIKE': {AppLanguage.de: 'Gefühlt', AppLanguage.en: 'Feels like'},
    'WIND': {AppLanguage.de: 'Wind', AppLanguage.en: 'Wind'},
    'HUMIDITY': {AppLanguage.de: 'Feuchte', AppLanguage.en: 'Humidity'},
    'SEARCH_CITY': {AppLanguage.de: 'Stadt suchen', AppLanguage.en: 'Search city'},
    'SEARCH_HINT': {AppLanguage.de: 'Nach Stadt suchen...', AppLanguage.en: 'Search for city...'},
    'NO_CITIES': {AppLanguage.de: 'Keine Städte gefunden', AppLanguage.en: 'No cities found'},
    'ENTER_CITY': {AppLanguage.de: 'Stadtname eingeben', AppLanguage.en: 'Enter city name'},
    'WEATHER_MAP': {AppLanguage.de: 'WETTERKARTE', AppLanguage.en: 'WEATHER MAP'},
    'STANDARD': {AppLanguage.de: 'Standard', AppLanguage.en: 'Standard'},
    'WEATHER_LAYER': {AppLanguage.de: 'Ebenen', AppLanguage.en: 'Layers'},
    'RAIN': {AppLanguage.de: 'Regen', AppLanguage.en: 'Rain'},
    'VISIBILITY': {AppLanguage.de: 'Sicht', AppLanguage.en: 'Vis'},
    'PRESSURE': {AppLanguage.de: 'Druck', AppLanguage.en: 'Pres'},
    'NOW': {AppLanguage.de: 'Jetzt', AppLanguage.en: 'Now'},
    'TODAY': {AppLanguage.de: 'Heute', AppLanguage.en: 'Today'},
  };

  String translate(String key) => _texts[key]?[_lang] ?? key;
  String customTranslate(String de, String en) => _lang == AppLanguage.de ? de : en;

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
}
