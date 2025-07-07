import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_logger.dart';

class ImagePreviewWidget extends StatelessWidget {
  final File imageFile;
  final VoidCallback onCancel;

  const ImagePreviewWidget({
    super.key,
    required this.imageFile,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Theme am Anfang holen
    AppLogger.debug("ImagePreviewWidget: Displaying image preview.");

    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
      height: 120,
      decoration: BoxDecoration(
        // OPTIMIERT: Verwendet eine semantische Farbe aus dem Theme
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              imageFile,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                AppLogger.error("ImagePreviewWidget: Error loading preview image file.", error, stackTrace);
                // OPTIMIERT: Der Fehlerzustand verwendet jetzt Theme-Farben
                return Container(
                  height: 100,
                  width: 100,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: Colors.transparent, // Transparent ist hier in Ordnung
              child: InkWell(
                onTap: onCancel,
                borderRadius: BorderRadius.circular(14),
                child: CircleAvatar(
                  radius: 14,
                  // OPTIMIERT: Verwendet eine dunkle, halbtransparente Farbe aus dem Theme
                  backgroundColor: theme.colorScheme.scrim.withOpacity(0.7),
                  child: Icon(
                    Icons.close,
                    // OPTIMIERT: Die Icon-Farbe ist jetzt an die Hintergrundfarbe gekoppelt
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}