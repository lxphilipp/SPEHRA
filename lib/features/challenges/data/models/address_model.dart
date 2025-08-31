import 'package:equatable/equatable.dart';

/// {@template address_model}
/// Represents a geographical address.
/// {@endtemplate}
class AddressModel extends Equatable {
  /// The display name of the address.
  final String displayName;

  /// The latitude of the address.
  final double latitude;

  /// The longitude of the address.
  final double longitude;

  /// {@macro address_model}
  const AddressModel({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  /// Creates an [AddressModel] from a map.
  ///
  /// The map is expected to contain the keys 'display_name', 'lat', and 'lon'.
  /// If 'display_name' is missing, it defaults to 'Unbekannter Ort'.
  /// If 'lat' or 'lon' are missing or cannot be parsed as doubles, they default to 0.0.
  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      displayName: map['display_name'] ?? 'Unbekannter Ort',
      latitude: double.tryParse(map['lat'] ?? '0.0') ?? 0.0,
      longitude: double.tryParse(map['lon'] ?? '0.0') ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [displayName, latitude, longitude];
}
