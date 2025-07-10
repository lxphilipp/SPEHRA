import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class AddressEntity extends Equatable {
  final String displayName;
  final LatLng point;

  const AddressEntity({required this.displayName, required this.point});

  @override
  List<Object?> get props => [displayName, point];
}