import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();

  static final StorageService instance =
      StorageService._();

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  // ==============================
  // UPLOAD FILE
  // ==============================

  Future<String?> uploadFile({
    required File file,
    required String folder,
    required String fileName,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child(folder)
          .child(fileName);

      await ref.putFile(file);

      final url =
          await ref.getDownloadURL();

      return url;
    } catch (e) {
      debugPrint('UPLOAD ERROR => $e');
      return null;
    }
  }

  // ==============================
  // DELETE FILE
  // ==============================

  Future<void> deleteFile(
    String url,
  ) async {
    try {
      await _storage
          .refFromURL(url)
          .delete();
    } catch (e) {
      debugPrint('DELETE FILE ERROR => $e');
    }
  }
}