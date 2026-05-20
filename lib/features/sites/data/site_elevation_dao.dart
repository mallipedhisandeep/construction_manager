import '../../../core/services/firebase_service.dart';

import 'site_elevation_model.dart';

class SiteElevationDao {
  final FirebaseService _firebase =
      FirebaseService.instance;

  // ==============================
  // INSERT ELEVATION
  // ==============================

  Future<void> insert(
    SiteElevationModel model,
  ) async {
    try {
      await _firebase
          .siteElevations
          .add(
        model.toMap(),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==============================
  // GET BY SITE
  // ==============================

  Future<List<SiteElevationModel>>
      getBySite(
    String siteId,
  ) async {
    try {
      final snapshot =
          await _firebase
              .siteElevations
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
          return SiteElevationModel
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

  Stream<List<SiteElevationModel>>
      watchBySite(
    String siteId,
  ) {
    return _firebase
        .siteElevations
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
            return SiteElevationModel
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
  // DELETE
  // ==============================

  Future<void> delete(
    String id,
  ) async {
    try {
      await _firebase
          .siteElevations
          .doc(id)
          .delete();
    } catch (e) {
      rethrow;
    }
  }
}