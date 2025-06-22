import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_logger.dart';

class ImagePreviewWidget extends StatelessWidget {
  final File imageFile;
  final VoidCallback onCancel; // Callback, wenn der User die Vorschau schließt

  const ImagePreviewWidget({
    super.key,
    required this.imageFile,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.debug("ImagePreviewWidget: Displaying image preview.");
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0), // Etwas Abstand
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1), // Leichter Hintergrund
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
              width: 100, // Quadratische Vorschau
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                AppLogger.error("ImagePreviewWidget: Error loading preview image file.", error, stackTrace);
                return Container(
                  height: 100, width: 100,
                  color: Colors.grey[700],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
                );
              },
            ),
          ),
          Positioned(
            top: 4,
            right: MediaQuery.of(context).size.width * 0.5 - 50 - 18, // Versuch der Zentrierung relativ zum Bild
            child: Material( // Material für den InkWell-Effekt
              color: Colors.transparent,
              child: InkWell(
                onTap: (){
                  AppLogger.debug("ImagePreviewWidget: Cancel button tapped.");
                  onCancel();
                },
                borderRadius: BorderRadius.circular(14),
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}