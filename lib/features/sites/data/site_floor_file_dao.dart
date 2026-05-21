import '../../../core/services/supabase_service.dart';

import 'site_floor_file_model.dart';

class SiteFloorFileDao {

  final SupabaseService _supabase =
      SupabaseService.instance;

  Future<List<SiteFloorFileModel>>
      getFiles(
    String siteId,
    int floorNo,
  ) async {

    try {

      final response =
          await _supabase
              .siteFloorFiles
              .select()
              .eq(
                'site_id',
                siteId,
              )
              .eq(
                'floor_no',
                floorNo,
              )
              .order(
                'uploaded_at',
                ascending: false,
              );

      return (response as List)
          .map(
        (doc) {

          return SiteFloorFileModel
              .fromMap(
            doc,
            doc['id'].toString(),
          );
        },
      ).toList();

    } catch (e) {

      return [];
    }
  }

  Future<int> countFiles(
    String siteId,
    int floorNo,
  ) async {

    final files =
        await getFiles(
      siteId,
      floorNo,
    );

    return files.length;
  }

  Future<void> insert(
    SiteFloorFileModel model,
  ) async {

    await _supabase
        .siteFloorFiles
        .insert(
          model.toMap(),
        );
  }

  Future<void> delete(
    String id,
  ) async {

    await _supabase
        .siteFloorFiles
        .delete()
        .eq(
          'id',
          id,
        );
  }
}