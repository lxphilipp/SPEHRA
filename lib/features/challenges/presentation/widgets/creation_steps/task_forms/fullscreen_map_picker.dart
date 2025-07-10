import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../providers/challenge_provider.dart';
import 'search_result_list_widget.dart';

class FullscreenMapPicker extends StatefulWidget {
  final LatLng initialCenter;
  final double initialRadius;

  const FullscreenMapPicker({
    super.key,
    required this.initialCenter,
    required this.initialRadius,
  });

  @override
  State<FullscreenMapPicker> createState() => _FullscreenMapPickerState();
}

class _FullscreenMapPickerState extends State<FullscreenMapPicker> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  late LatLng _pickedLocation;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialCenter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeProvider>().clearLocationSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChallengeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // Die Suchleiste ist jetzt Teil der AppBar
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration.collapsed(hintText: 'Ort suchen...'),
          onSubmitted: (_) => provider.searchLocation(_searchController.text),
        ),
        actions: [
          provider.isSearchingLocation
              ? const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)))
              : IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Suchen',
            onPressed: () => provider.searchLocation(_searchController.text),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Ort bestätigen',
            onPressed: () => Navigator.of(context).pop(_pickedLocation),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialCenter,
              initialZoom: 15.0,
              onMapEvent: (event) {
                if (event is MapEventMove) {
                  setState(() => _pickedLocation = event.camera.center);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _pickedLocation,
                    radius: widget.initialRadius,
                    useRadiusInMeter: true,
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    borderColor: theme.colorScheme.primary,
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
          // Die Suchergebnisse werden in einem schicken, ausziehbaren Sheet angezeigt
          if (provider.locationSearchResults.isNotEmpty)
            DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.15,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2)
                            ),
                          ),
                        ),
                      ),
                      SearchResultList(
                        searchResults: provider.locationSearchResults,
                        onLocationSelected: (location) {
                          _mapController.move(location, 15.0);
                          provider.clearLocationSearch();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}