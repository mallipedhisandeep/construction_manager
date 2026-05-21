import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  StorageService._();

  static final StorageService instance =
      StorageService._();

  final SupabaseClient _client =
      Supabase.instance.client;

  static const String _bucket =
      'construction-files';

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
          .from(_bucket)
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
              .from(_bucket)
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
    String urlOrPath,
  ) async {
    try {
      String path = urlOrPath;

      if (urlOrPath.startsWith(
        'http',
      )) {
        final uri =
            Uri.parse(urlOrPath);

        final segments =
            uri.pathSegments;

        final bucketIndex =
            segments.indexOf(
          _bucket,
        );

        if (bucketIndex != -1 &&
            bucketIndex + 1 <
                segments.length) {
          path = segments
              .sublist(
                bucketIndex + 1,
              )
              .join('/');
        }
      }

      await _client.storage
          .from(_bucket)
          .remove([path]);
    } catch (e) {
      debugPrint(
        'DELETE FILE ERROR => $e',
      );
    }
  }
}