import 'package:latlong2/latlong.dart';

/// An abstract contract for all device-specific tracking functions.
/// The domain layer only depends on this interface.
abstract class DeviceTrackingRepository {
  /// Fetches the number of steps taken today.
  Future<int> getTodaysSteps();

  /// Checks if the user is at a specific location.
  Future<bool> isUserAtLocation(LatLng targetLocation, double radiusInMeters);
}