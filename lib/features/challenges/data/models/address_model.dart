import 'package:equatable/equatable.dart';

class AddressModel extends Equatable {
  final String displayName;
  final double latitude;
  final double longitude;

  const AddressModel({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

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