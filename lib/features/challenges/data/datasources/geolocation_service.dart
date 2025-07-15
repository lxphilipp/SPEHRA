import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Ein Service, der die Kommunikation mit dem Geolocator-Paket kapselt.
class GeolocationService {

  /// Holt die aktuelle Position des Nutzers.
  /// Diese Methode kümmert sich um die Abfrage von Berechtigungen.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Prüfen, ob die Standortdienste des Geräts aktiviert sind.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Standortdienste sind deaktiviert.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Standortberechtigungen wurden verweigert.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Berechtigungen wurden dauerhaft verweigert.
      return Future.error(
          'Standortberechtigungen sind dauerhaft verweigert, wir können keine Anfrage stellen.');
    }

    // Wenn wir hier ankommen, sind die Berechtigungen erteilt.
    return await Geolocator.getCurrentPosition();
  }

  /// Berechnet die Distanz zwischen zwei geografischen Punkten in Metern.
  double getDistanceInMeters(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
        start.latitude, start.longitude,
        end.latitude, end.longitude
    );
  }

  /// Die primäre öffentliche Methode. Prüft, ob der Nutzer sich innerhalb eines
  /// bestimmten Radius um ein Ziel befindet.
  Future<bool> isUserAtLocation(LatLng targetLocation, double radiusInMeters) async {
    try {
      final currentPosition = await _determinePosition();
      final distance = getDistanceInMeters(
        LatLng(currentPosition.latitude, currentPosition.longitude),
        targetLocation,
      );

      return distance <= radiusInMeters;

    } catch (e) {
      // Leitet Fehler (z.B. keine Berechtigung) an den Aufrufer weiter.
      rethrow;
    }
  }
}