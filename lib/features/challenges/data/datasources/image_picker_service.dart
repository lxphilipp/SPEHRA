import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Ein abstrakter Vertrag, der definiert, was der Service können muss.
/// Der Domain-Layer wird nur dieses Interface kennen.
abstract class ImagePickerService {
  Future<File?> pickImageFromGallery();
}


/// Die konkrete Implementierung, die das image_picker-Paket verwendet.
class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<File?> pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Bilder leicht komprimieren
        maxWidth: 1024,  // Bilder für die Anzeige verkleinern
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null; // Nutzer hat die Auswahl abgebrochen
    } catch (e) {
      // Fehler beim Öffnen der Galerie oder bei Berechtigungen
      print("ImagePickerService Error: $e");
      rethrow; // Fehler weitergeben, damit der Use Case ihn behandeln kann
    }
  }
}