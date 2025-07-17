import 'package:health/health.dart';
import 'package:flutter/foundation.dart';

class HealthService {
  final Health health = Health();

  // Define types and permissions here once,
  // so they are consistent across both methods.
  static const types = [HealthDataType.STEPS];
  static const permissions = [HealthDataAccess.READ];

  /// Requests the necessary permissions from the user.
  Future<bool> requestPermissions() async {
    try {
      // Request authorization.
      final bool requested = await health.requestAuthorization(types, permissions: permissions);
      return requested;
    } catch (e) {
      debugPrint("Error requesting Health permissions: $e");
      return false;
    }
  }

  /// Fetches the total number of steps for today.
  Future<int> getStepsToday() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {

      final bool hasPermissions = await health.hasPermissions(types, permissions: permissions) ?? false;

      if (!hasPermissions) {
        final granted = await requestPermissions();
        if (!granted) {
          debugPrint("Permissions were not granted.");
          return 0;
        }
      }
      return await health.getTotalStepsInInterval(midnight, now) ?? 0;
    } catch (e) {
      debugPrint("Error retrieving step data: $e");
      return 0;
    }
  }
}