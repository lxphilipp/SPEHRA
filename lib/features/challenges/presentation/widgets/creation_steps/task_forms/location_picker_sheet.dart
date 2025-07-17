import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/address_entity.dart';
import '../../../providers/challenge_provider.dart';

class LocationPickerSheet extends StatefulWidget {
  final LatLng initialCenter;
  final double initialRadius;

  const LocationPickerSheet({
    super.key,
    required this.initialCenter,
    required this.initialRadius,
  });

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}
class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final MapController _mapController = MapController();
  final SearchController _searchController = SearchController();
  Timer? _debounceTimer;

  late LatLng _currentSelection;
  late double _currentRadius;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.initialCenter;
    _currentRadius = widget.initialRadius;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<List<AddressEntity>> _searchLocations(String query) async {
    if (query.isEmpty) return [];

    final completer = Completer<List<AddressEntity>>();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        await context.read<ChallengeProvider>().searchLocation(query);
        final provider = context.read<ChallengeProvider>();
        completer.complete(provider.locationSearchResults);
      } catch (e) {
        completer.complete([]);
      }
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Set Location and Radius'),
          leading: const CloseButton(),
          centerTitle: true,
          elevation: 0,
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: 15,
                onMapEvent: (event) {
                  if (event is MapEventMove) {
                    setState(() => _currentSelection = event.camera.center);
                  }
                },
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
                      point: _currentSelection,
                      radius: _currentRadius,
                      useRadiusInMeter: true,
                      color: Colors.red.withOpacity(0.2),
                      borderColor: Colors.red.withOpacity(0.6),
                      borderStrokeWidth: 2,
                    )
                  ],
                ),
              ],
            ),
            const Center(
              child: IgnorePointer(
                child: Icon(Icons.location_pin, size: 50, color: Colors.red),
              ),
            ),

            // KORREKTE SearchAnchor Implementierung mit FutureBuilder Pattern
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchAnchor.bar(
                searchController: _searchController,
                barHintText: 'Search location...',
                suggestionsBuilder: (BuildContext context, SearchController controller) {
                  final query = controller.text;

                  if (query.isEmpty) {
                    return <Widget>[];
                  }

                  // FutureBuilder Pattern für asynchrone Suchen
                  return <Widget>[
                    FutureBuilder<List<AddressEntity>>(
                      future: _searchLocations(query),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            leading: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            title: Text('Searching...'),
                          );
                        }

                        if (snapshot.hasError) {
                          return const ListTile(
                            leading: Icon(Icons.error),
                            title: Text('Error during search'),
                          );
                        }

                        final results = snapshot.data ?? [];

                        if (results.isEmpty) {
                          return const ListTile(
                            title: Text('No results found'),
                          );
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: results.map((result) {
                            return ListTile(
                              leading: const Icon(Iconsax.location),
                              title: Text(result.displayName),
                              onTap: () {
                                controller.closeView(result.displayName);
                                _mapController.move(result.point, 15.0);
                                FocusScope.of(context).unfocus();
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ];
                },
              ),
            ),

            Positioned(
              bottom: 80,
              left: 10,
              right: 10,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(Iconsax.radar),
                      Expanded(
                        child: Slider(
                          value: _currentRadius,
                          min: 10,
                          max: 1000,
                          divisions: 99,
                          label: '${_currentRadius.toInt()} m',
                          onChanged: (double value) {
                            setState(() {
                              _currentRadius = value;
                            });
                          },
                        ),
                      ),
                      Text('${_currentRadius.toInt()}m'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _debounceTimer?.cancel();
            if (_searchController.isOpen) {
              _searchController.closeView('');
            }

            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted && Navigator.of(context).canPop()) {
                final result = {
                  'location': _currentSelection,
                  'radius': _currentRadius
                };
                Navigator.of(context).pop(result);
              }
            });
          },
          label: const Text("Confirm Location"),
          icon: const Icon(Iconsax.check),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}