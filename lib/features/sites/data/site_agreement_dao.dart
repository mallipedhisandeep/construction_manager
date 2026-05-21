import '../../../core/services/supabase_service.dart';

import 'site_agreement_model.dart';

class SiteAgreementDao {
  final SupabaseService _supabase =
      SupabaseService.instance;

  // =========================
  // WATCH BY SITE
  // =========================

  Stream<List<SiteAgreementModel>>
      watchAllBySite(
    String siteId,
  ) {
    return _supabase
        .siteAgreements
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
                  SiteAgreementModel.fromMap(
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

  Future<void> insertAgreement(
    SiteAgreementModel model,
  ) async {
    await _supabase.siteAgreements
        .insert(
      model.toMap(),
    );
  }

  // =========================
  // DELETE
  // =========================

  Future<void> deleteAgreement(
    String id,
  ) async {
    await _supabase.siteAgreements
        .delete()
        .eq('id', id);
  }
}