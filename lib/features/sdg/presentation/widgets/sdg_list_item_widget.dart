import 'package:flutter/material.dart';
import '../../domain/entities/sdg_list_item_entity.dart';

class SdgListItemWidget extends StatelessWidget {
  final SdgListItemEntity sdgItem;
  final VoidCallback onTap;

  const SdgListItemWidget({
    super.key,
    required this.sdgItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Card( // Card für einen schönen Look mit Schatten etc.
        color: theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest,
        elevation: theme.cardTheme.elevation ?? 2.0,
        shape: theme.cardTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias, // Um sicherzustellen, dass das Bild die Ecken der Karte respektiert
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3, // Mehr Platz für das Bild
              child: Image.asset(
                sdgItem.listImageAssetPath, // Pfad aus der Entity
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image, size: 40)),
              ),
            ),
            Expanded(
              flex: 1, // Weniger Platz für den Titel
              child: Container(
                padding: const EdgeInsets.all(8.0),
                // Optional: Hintergrundfarbe für den Titelbereich
                // color: theme.colorScheme.surface.withOpacity(0.8),
                child: Center(
                  child: Text(
                    sdgItem.title,
                    style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurface),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}