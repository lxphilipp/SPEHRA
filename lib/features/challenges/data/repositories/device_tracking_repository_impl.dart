import 'package:latlong2/latlong.dart';
import '../../domain/repositories/device_tracking_repository.dart';
import '../datasources/geolocation_service.dart';
import '../datasources/health_service.dart';

/// Implements the [DeviceTrackingRepository] interface.
///
/// This repository is responsible for handling device tracking functionalities
/// such as retrieving step counts and checking user location.
class DeviceTrackingRepositoryImpl implements DeviceTrackingRepository {
  /// The geolocation service used to interact with device location.
  final GeolocationService _geolocationService;

  /// The health service used to interact with device health data like step counts.
  final HealthService _healthService;

  /// Creates an instance of [DeviceTrackingRepositoryImpl].
  ///
  /// Requires a [GeolocationService] and a [HealthService].
  DeviceTrackingRepositoryImpl({
    required GeolocationService geolocationService,
    required HealthService healthService,
  })  : _geolocationService = geolocationService,
        _healthService = healthService;

  @override
  Future<int> getTodaysSteps() {
    return _healthService.getStepsToday();
  }

  @override
  Future<bool> isUserAtLocation(LatLng targetLocation, double radiusInMeters) {
    return _geolocationService.isUserAtLocation(targetLocation, radiusInMeters);
  }
}