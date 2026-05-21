import '../../../core/services/supabase_service.dart';

import 'site_agreement_model.dart';

class SiteAgreementDao {

  final SupabaseService _supabase =
      SupabaseService.instance;

  Future<void> insertAgreement(
    SiteAgreementModel agreement,
  ) async {

    await _supabase.siteAgreements
        .insert(
          agreement.toMap(),
        );
  }

  Future<List<SiteAgreementModel>>
      getBySite(
    String siteId,
  ) async {

    try {

      final response =
          await _supabase
              .siteAgreements
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

          return SiteAgreementModel
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

  Future<void> deleteAgreement(
    String id,
  ) async {

    await _supabase
        .siteAgreements
        .delete()
        .eq(
          'id',
          id,
        );
  }
}