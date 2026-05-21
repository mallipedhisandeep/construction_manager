import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {

  StorageService._();

  static final StorageService instance =
      StorageService._();

  final SupabaseClient _client =
      Supabase.instance.client;

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

      final path =
          '$folder/$cleanFileName';

      await _client.storage
          .from('construction-files')
          .uploadBinary(
            path,
            bytes,
            fileOptions:
                const FileOptions(
              upsert: true,
            ),
          );

      final url =
          _client.storage
              .from(
                'construction-files',
              )
              .getPublicUrl(path);

      return url;

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
    String path,
  ) async {

    try {

      await _client.storage
          .from(
            'construction-files',
          )
          .remove([path]);

    } catch (e) {

      debugPrint(
        'DELETE FILE ERROR => $e',
      );
    }
  }
}