import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<String> getCurrentLocation() async {
    try {
      // ✅ Ensure Location Services are Enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings(); // Prompt user to enable
        return "Location services are disabled";
      }

      // ✅ Request Location Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return "Location permission denied";
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return "Permission permanently denied";
      }

      // ✅ Get Current Location with GPS Accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation, // 🔥 Most accurate
        forceAndroidLocationManager: true, // 🔥 Ensures GPS is used
        timeLimit: Duration(seconds: 10), // 🔥 Prevents indefinite waiting
      );

      print("📍 Accurate Location: ${position.latitude}, ${position.longitude}");
      return "${position.latitude}, ${position.longitude}";
    } catch (e) {
      return "Error fetching location: ${e.toString()}";
    }
  }
}
