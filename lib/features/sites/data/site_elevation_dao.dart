import '../../../core/services/supabase_service.dart';

import 'site_elevation_model.dart';

class SiteElevationDao {

  final SupabaseService _supabase =
      SupabaseService.instance;

  Future<void> insert(
    SiteElevationModel model,
  ) async {

    await _supabase
        .siteElevations
        .insert(
          model.toMap(),
        );
  }

  Future<List<SiteElevationModel>>
      getBySite(
    String siteId,
  ) async {

    try {

      final response =
          await _supabase
              .siteElevations
              .select()
              .eq(
                'site_id',
                siteId,
              )
              .order(
                'created_at',
                ascending: false,
              );

      return (response as List)
          .map(
        (doc) {

          return SiteElevationModel
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

  Future<void> delete(
    String id,
  ) async {

    await _supabase
        .siteElevations
        .delete()
        .eq(
          'id',
          id,
        );
  }
}