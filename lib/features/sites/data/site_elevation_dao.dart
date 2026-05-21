import '../../../core/services/supabase_service.dart';

import 'site_elevation_model.dart';

class SiteElevationDao {
  final SupabaseService _supabase =
      SupabaseService.instance;

  // =========================
  // WATCH BY SITE
  // =========================

  Stream<List<SiteElevationModel>>
      watchAllBySite(
    String siteId,
  ) {
    return _supabase
        .siteElevations
        .stream(
          primaryKey: ['id'],
        )
        .eq('site_id', siteId)
        .order(
          'created_at',
          ascending: false,
        )
        .map(
      (rows) {
        return rows
            .map(
              (e) =>
                  SiteElevationModel.fromMap(
                e,
                e['id'].toString(),
              ),
            )
            .toList();
      },
    );
  }

  // =========================
  // INSERT
  // =========================

  Future<void> insert(
    SiteElevationModel model,
  ) async {
    await _supabase.siteElevations
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
    await _supabase.siteElevations
        .delete()
        .eq('id', id);
  }
}