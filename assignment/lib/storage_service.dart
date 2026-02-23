import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;
  static const _opTimeout = Duration(seconds: 30);

  Future<String> uploadAssetImage({
    required String assetId,
    required File file,
  }) async {
    final ref = _storage.ref('assets/$assetId/main.jpg');
    await ref.putFile(file).timeout(_opTimeout);
    return await ref.getDownloadURL().timeout(_opTimeout);
  }

  Future<void> deleteAssetImage(String assetId) async {
    final ref = _storage.ref('assets/$assetId/main.jpg');
    try {
      await ref.delete().timeout(_opTimeout);
    } catch (_) {
      // ignore (file may not exist)
    }
  }
}
