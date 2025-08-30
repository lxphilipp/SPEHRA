import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import '../../../../domain/entities/address_entity.dart';

/// A reusable widget to display a list of location search results.
class SearchResultList extends StatelessWidget {
  final List<AddressEntity> searchResults;
  final Function(LatLng) onLocationSelected;

  const SearchResultList({
    super.key,
    required this.searchResults,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return ListTile(
            leading: const Icon(Iconsax.location_tick),
            title: Text(
              result.displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            dense: true,
            onTap: () => onLocationSelected(result.point),
          );
        },
      ),
    );
  }
}