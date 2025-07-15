// lib/features/challenges/domain/repositories/device_tracking_repository.dart
import 'package:latlong2/latlong.dart';

/// Ein abstrakter Vertrag für alle gerätespezifischen Tracking-Funktionen.
/// Die Domain-Schicht hängt nur von diesem Interface ab.
abstract class DeviceTrackingRepository {
  /// Holt die Anzahl der Schritte, die heute gemacht wurden.
  Future<int> getTodaysSteps();

  /// Prüft, ob sich der Nutzer an einem bestimmten Ort befindet.
  Future<bool> isUserAtLocation(LatLng targetLocation, double radiusInMeters);

// Hier könntest du zukünftig weitere Methoden hinzufügen, z.B. für Bild-Uploads.
// Future<String> uploadChallengeProofImage(File image);
}