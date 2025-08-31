import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// Represents a geographical address.
class AddressEntity extends Equatable {
  /// A human-readable representation of the address.
  final String displayName;

  /// The geographical coordinates of the address.
  final LatLng point;

  /// Creates an [AddressEntity].
  ///
  /// [displayName] is the human-readable representation of the address.
  /// [point] is the geographical coordinates of the address.
  const AddressEntity({required this.displayName, required this.point});

  @override
  List<Object?> get props => [displayName, point];
}
