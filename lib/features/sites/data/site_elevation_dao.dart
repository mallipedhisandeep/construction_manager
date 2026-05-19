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
      await _firebase.siteElevations.add(
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
    } catch (e) {
      rethrow;
    }
  }
}