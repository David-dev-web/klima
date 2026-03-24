import 'package:geolocator/geolocator.dart';

class LocationService {
  // Default fallback: Berlin
  static const double defaultLat = 52.52;
  static const double defaultLon = 13.41;
  static const String defaultName = 'Berlin, DE';

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      serviceEnabled = false;
    }

    if (!serviceEnabled) {
      // Don't throw, return the fallback manually handled in home_page or throw for explicitly catching it
      throw const LocationException('Standortdienste deaktiviert');
    }

    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
         throw const LocationException('Standortberechtigung verweigert');
      }
    }

    if (permission == LocationPermission.deniedForever) {
       throw const LocationException('Dauerhaft verweigert');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }
}

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}
