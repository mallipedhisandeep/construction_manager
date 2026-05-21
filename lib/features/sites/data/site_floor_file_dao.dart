import '../../../core/services/supabase_service.dart';

import 'site_floor_file_model.dart';

class SiteFloorFileDao {
  final SupabaseService _supabase =
      SupabaseService.instance;

  // =========================
  // WATCH ALL
  // =========================

  Stream<List<SiteFloorFileModel>>
      watchAll(
    String siteId,
    int floorNo,
  ) {
    return _supabase.client
        .from('site_floor_files')
        .stream(
          primaryKey: ['id'],
        )
        .map(
      (rows) {
        final filtered =
            rows.where(
          (e) =>
              e['site_id'] ==
                  siteId &&
              e['floor_no'] ==
                  floorNo,
        );

        final list =
            filtered
                .map(
                  (e) =>
                      SiteFloorFileModel.fromMap(
                    e,
                    e['id']
                        .toString(),
                  ),
                )
                .toList();

        list.sort(
          (a, b) {
            final aDate =
                a.uploadedAt ??
                    DateTime(2000);

            final bDate =
                b.uploadedAt ??
                    DateTime(2000);

            return bDate.compareTo(
              aDate,
            );
          },
        );

        return list;
      },
    );
  }

  // =========================
  // INSERT
  // =========================

  Future<void> insert(
    SiteFloorFileModel model,
  ) async {
    await _supabase.siteFloorFiles
        .insert(
      model.toMap(),
    );
  }

  // =========================
  // DELETE
  // =========================

  Future<void> delete(
    String id,
  ) async {
    await _supabase.siteFloorFiles
        .delete()
        .eq('id', id);
  }

  // =========================
  // COUNT
  // =========================

  Future<int> countFiles(
    String siteId,
    int floorNo,
  ) async {
    final result =
        await _supabase.siteFloorFiles
            .select()
            .eq('site_id', siteId)
            .eq(
              'floor_no',
              floorNo,
            );

    return result.length;
  }
}