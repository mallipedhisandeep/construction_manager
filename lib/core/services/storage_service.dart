import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  StorageService._();

  static final StorageService instance =
      StorageService._();

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  // ==============================
  // WEB FILE UPLOAD
  // ==============================

  Future<String?> uploadWebFile({
    required Uint8List bytes,
    required String folder,
    required String fileName,
  }) async {
    try {
      final cleanFileName =
          fileName.replaceAll(
        ' ',
        '_',
      );

      final ref = _storage
          .ref()
          .child(folder)
          .child(cleanFileName);

      final metadata = SettableMetadata(
        contentType:
            _getContentType(
          cleanFileName,
        ),
      );

      await ref.putData(
        bytes,
        metadata,
      );

      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint(
        'WEB UPLOAD ERROR => $e',
      );

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
      if (url.isEmpty) {
        return;
      }

      await _storage
          .refFromURL(url)
          .delete();
    } catch (e) {
      debugPrint(
        'DELETE FILE ERROR => $e',
      );
    }
  }

  // ==============================
  // CONTENT TYPE
  // ==============================

  String _getContentType(
    String fileName,
  ) {
    final lower =
        fileName.toLowerCase();

    if (lower.endsWith('.pdf')) {
      return 'application/pdf';
    }

    if (lower.endsWith('.png')) {
      return 'image/png';
    }

    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }

    return 'application/octet-stream';
  }
}