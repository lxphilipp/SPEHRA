// lib/features/challenges/domain/repositories/device_tracking_repository.dart
import 'package:latlong2/latlong.dart';

/// An abstract contract for all device-specific tracking functions.
/// The domain layer only depends on this interface.
abstract class DeviceTrackingRepository {
  /// Fetches the number of steps taken today.
  Future<int> getTodaysSteps();

  /// Checks if the user is at a specific location.
  Future<bool> isUserAtLocation(LatLng targetLocation, double radiusInMeters);

// Here you could add more methods in the future, e.g., for image uploads.
// Future<String> uploadChallengeProofImage(File image);
}