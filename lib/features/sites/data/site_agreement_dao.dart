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
    } catch (e) {
      rethrow;
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
          await _firebase
              .siteAgreements
              .where(
                'site_id',
                isEqualTo: siteId,
              )
              .orderBy(
                'created_at',
                descending: true,
              )
              .get();

      return snapshot.docs.map(
        (doc) {
          return SiteAgreementModel
              .fromMap(
            doc.data(),
            doc.id,
          );
        },
      ).toList();
    } catch (e) {
      return [];
    }
  }

  // ==============================
  // REALTIME STREAM
  // ==============================

  Stream<List<SiteAgreementModel>>
      watchBySite(
    String siteId,
  ) {
    return _firebase
        .siteAgreements
        .where(
          'site_id',
          isEqualTo: siteId,
        )
        .orderBy(
          'created_at',
          descending: true,
        )
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            return SiteAgreementModel
                .fromMap(
              doc.data(),
              doc.id,
            );
          },
        ).toList();
      },
    );
  }

  // ==============================
  // DELETE AGREEMENT
  // ==============================

  Future<void> deleteAgreement(
    String id,
  ) async {
    try {
      await _firebase
          .siteAgreements
          .doc(id)
          .delete();
    } catch (e) {
      rethrow;
    }
  }
}