import 'package:latlong2/latlong.dart';
import '../../domain/repositories/device_tracking_repository.dart';
import '../datasources/geolocation_service.dart';
import '../datasources/health_service.dart';

class DeviceTrackingRepositoryImpl implements DeviceTrackingRepository {
  final GeolocationService _geolocationService;
  final HealthService _healthService;

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