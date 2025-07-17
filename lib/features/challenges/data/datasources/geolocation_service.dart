import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// A service that encapsulates communication with the Geolocator package.
class GeolocationService {

  /// Fetches the user's current position.
  /// This method handles permission requests.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled on the device.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions were denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied.
      return Future.error(
          'Location permissions are permanently denied, we cannot request them.');
    }

    // If we reach here, permissions are granted.
    return await Geolocator.getCurrentPosition();
  }

  /// Calculates the distance between two geographical points in meters.
  double getDistanceInMeters(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
        start.latitude, start.longitude,
        end.latitude, end.longitude
    );
  }

  /// The primary public method. Checks if the user is within a
  /// certain radius of a target location.
  Future<bool> isUserAtLocation(LatLng targetLocation, double radiusInMeters) async {
    try {
      final currentPosition = await _determinePosition();
      final distance = getDistanceInMeters(
        LatLng(currentPosition.latitude, currentPosition.longitude),
        targetLocation,
      );

      return distance <= radiusInMeters;

    } catch (e) {
      // Forwards errors (e.g., no permission) to the caller.
      rethrow;
    }
  }
}