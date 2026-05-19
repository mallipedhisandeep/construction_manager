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

      await _firebase.siteElevations
          .add(
        model.toMap(),
      );

      print(
        'SITE ELEVATION INSERTED',
      );

    } catch (e) {

      print(
        'INSERT ELEVATION ERROR => $e',
      );
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
          await _firebase.siteElevations

              .where(
                'site_id',
                isEqualTo: siteId,
              )

              .orderBy(
                'created_at',
                descending: true,
              )

              .get();

      final elevations =
          snapshot.docs.map(
        (doc) {

          return SiteElevationModel
              .fromMap(

            doc.data()
                as Map<String, dynamic>,

            doc.id,
          );
        },
      ).toList();

      return elevations;

    } catch (e) {

      print(
        'GET ELEVATIONS ERROR => $e',
      );

      return [];
    }
  }

  // ==============================
  // DELETE ELEVATION
  // ==============================

  Future<void> delete(
    String id,
  ) async {

    try {

      await _firebase.siteElevations
          .doc(id)
          .delete();

      print(
        'SITE ELEVATION DELETED',
      );

    } catch (e) {

      print(
        'DELETE ELEVATION ERROR => $e',
      );
    }
  }
}