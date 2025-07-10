import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'location_picker_sheet.dart'; // Import des BottomSheet-Widgets

class LocationVisitTaskForm extends StatefulWidget {
  final TextEditingController descriptionController;
  final TextEditingController radiusController;
  final Function(LatLng) onLocationChanged;
  final LatLng initialLocation;

  const LocationVisitTaskForm({
    super.key,
    required this.descriptionController,
    required this.radiusController,
    required this.onLocationChanged,
    required this.initialLocation,
  });

  @override
  State<LocationVisitTaskForm> createState() => _LocationVisitTaskFormState();
}

class _LocationVisitTaskFormState extends State<LocationVisitTaskForm> {
  final MapController _mapController = MapController();
  final TextEditingController _addressController =
  TextEditingController();
  late LatLng _currentCenter;
  double _currentRadius = 50.0;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialLocation;
    _fetchAddressForLocation(_currentCenter);

    // Initialen Wert für den Radius-Controller setzen
    widget.radiusController.text = _currentRadius.toStringAsFixed(0);

    widget.radiusController.addListener(() {
      final newRadius = double.tryParse(widget.radiusController.text);
      if (newRadius != null && newRadius > 0) {
        setState(() => _currentRadius = newRadius);
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // In LocationVisitTaskForm - ändere den Aufruf:
  void _openLocationPicker() async {
    FocusScope.of(context).unfocus();

    final Map<String, dynamic>? result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationPickerSheet(
        initialCenter: _currentCenter,
        initialRadius: _currentRadius,
      ),
    );

    if (result != null) {
      final LatLng newLocation = result['location'] as LatLng;
      final double newRadius = (result['radius'] as num).toDouble();

      setState(() {
        _currentCenter = newLocation;
        _currentRadius = newRadius;
      });

      widget.onLocationChanged(newLocation);
      widget.radiusController.text = newRadius.toStringAsFixed(0);
      _mapController.move(newLocation, _mapController.camera.zoom);
      _fetchAddressForLocation(newLocation);
    }
  }

  Future<void> _fetchAddressForLocation(LatLng location) async {
    setState(() {
      _addressController.text = 'Adresse wird geladen...';
    });

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}');

    try {
      final response = await http.get(url, headers: {'User-Agent': 'de.meine.app'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _addressController.text = data['display_name'] ?? 'Adresse nicht gefunden';
        });
      } else {
        setState(() {
          _addressController.text = 'Adresse nicht verfügbar';
        });
      }
    } catch (e) {
      setState(() {
        _addressController.text = 'Fehler beim Laden der Adresse';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.descriptionController,
          decoration: const InputDecoration(labelText: 'Aufgabenbeschreibung'),
          autofocus: true,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.radiusController,
          decoration: const InputDecoration(labelText: 'Radius in Metern', hintText: 'z.B. 50'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Standort',
            suffixIcon: Icon(Icons.map_outlined),
          ),
          onTap: _openLocationPicker,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: IgnorePointer(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentCenter,
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(flags: ~InteractiveFlag.all),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.flutter_sdg',
                    tileProvider: CancellableNetworkTileProvider(),
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _currentCenter,
                        radius: _currentRadius,
                        useRadiusInMeter: true,
                        color: Colors.blue.withOpacity(0.3),
                        borderColor: Colors.blue,
                        borderStrokeWidth: 2,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}