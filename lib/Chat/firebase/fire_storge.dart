import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sdg/Chat/firebase/fire_database.dart';

class FireStorage {
  final FirebaseStorage fireStorage = FirebaseStorage.instance;

  Future<void> sendImage(
      {required File file, required String roomId, required String uid}) async {
    String ext = file.path.split('.').last;
    final ref = fireStorage
        .ref()
        .child('image/$roomId/${DateTime.now().millisecondsSinceEpoch}.$ext');

    await ref.putFile(file);

    String imageUrl = await ref.getDownloadURL();
    FireData().sendMessage(uid, imageUrl, roomId, type: 'image');
  }
}
