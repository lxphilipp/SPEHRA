import 'package:health/health.dart';
import 'package:flutter/foundation.dart';

class HealthService {
  final Health health = Health();

  // Definiere die Typen und Berechtigungen hier einmal,
  // damit sie in beiden Methoden konsistent sind.
  static const types = [HealthDataType.STEPS];
  static const permissions = [HealthDataAccess.READ];

  /// Fragt die notwendigen Berechtigungen beim Nutzer an.
  Future<bool> requestPermissions() async {
    try {
      // Fordere die Autorisierung an.
      final bool requested = await health.requestAuthorization(types, permissions: permissions);
      return requested;
    } catch (e) {
      debugPrint("Fehler beim Anfordern der Health-Berechtigungen: $e");
      return false;
    }
  }

  /// Holt die Gesamtzahl der Schritte für den heutigen Tag.
  Future<int> getStepsToday() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {

      final bool hasPermissions = await health.hasPermissions(types, permissions: permissions) ?? false;

      if (!hasPermissions) {
        final granted = await requestPermissions();
        if (!granted) {
          debugPrint("Berechtigungen wurden nicht erteilt.");
          return 0;
        }
      }
      return await health.getTotalStepsInInterval(midnight, now) ?? 0;
    } catch (e) {
      debugPrint("Fehler beim Abrufen der Schrittdaten: $e");
      return 0;
    }
  }
}