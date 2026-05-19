import '../../../core/services/firebase_service.dart';

import 'site_agreement_model.dart';

class SiteAgreementDao {

  final FirebaseService _firebase =
      FirebaseService.instance;

  // ==============================
  // INSERT AGREEMENT
  // ==============================

  Future<void> insertAgreement(
    SiteAgreementModel agreement,
  ) async {

    try {

      await _firebase.siteAgreements
          .add(
        agreement.toMap(),
      );

      print(
        'AGREEMENT INSERTED',
      );

    } catch (e) {

      print(
        'INSERT AGREEMENT ERROR => $e',
      );
    }
  }

  // ==============================
  // GET AGREEMENTS BY SITE
  // ==============================

  Future<List<SiteAgreementModel>>
      getBySite(
    String siteId,
  ) async {

    try {

      final snapshot =
          await _firebase.siteAgreements

              .where(
                'site_id',
                isEqualTo: siteId,
              )

              .orderBy(
                'created_at',
                descending: true,
              )

              .get();

      final agreements =
          snapshot.docs.map(
        (doc) {

          return SiteAgreementModel
              .fromMap(

            doc.data()
                as Map<String, dynamic>,

            doc.id,
          );
        },
      ).toList();

      return agreements;

    } catch (e) {

      print(
        'GET AGREEMENTS ERROR => $e',
      );

      return [];
    }
  }

  // ==============================
  // DELETE AGREEMENT
  // ==============================

  Future<void> deleteAgreement(
    String id,
  ) async {

    try {

      await _firebase.siteAgreements
          .doc(id)
          .delete();

      print(
        'AGREEMENT DELETED',
      );

    } catch (e) {

      print(
        'DELETE AGREEMENT ERROR => $e',
      );
    }
  }
}