import '../../../core/services/firebase_service.dart';

import 'site_floor_file_model.dart';

class SiteFloorFileDao {
  final FirebaseService _firebase =
      FirebaseService.instance;

  // ==============================
  // GET FILES
  // ==============================

  Future<List<SiteFloorFileModel>>
      getFiles(
    String siteId,
    int floorNo,
  ) async {
    try {
      final snapshot =
          await _firebase
              .siteFloorFiles
              .where(
                'site_id',
                isEqualTo: siteId,
              )
              .where(
                'floor_no',
                isEqualTo: floorNo,
              )
              .orderBy(
                'uploaded_at',
                descending: true,
              )
              .get();

      return snapshot.docs.map(
        (doc) {
          return SiteFloorFileModel
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

  Stream<List<SiteFloorFileModel>>
      watchFiles(
    String siteId,
    int floorNo,
  ) {
    return _firebase
        .siteFloorFiles
        .where(
          'site_id',
          isEqualTo: siteId,
        )
        .where(
          'floor_no',
          isEqualTo: floorNo,
        )
        .orderBy(
          'uploaded_at',
          descending: true,
        )
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            return SiteFloorFileModel
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
  // COUNT FILES
  // ==============================

  Future<int> countFiles(
    String siteId,
    int floorNo,
  ) async {
    try {
      final snapshot =
          await _firebase
              .siteFloorFiles
              .where(
                'site_id',
                isEqualTo: siteId,
              )
              .where(
                'floor_no',
                isEqualTo: floorNo,
              )
              .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // ==============================
  // INSERT FILE
  // ==============================

  Future<void> insert(
    SiteFloorFileModel model,
  ) async {
    try {
      await _firebase
          .siteFloorFiles
          .add(
        model.toMap(),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==============================
  // DELETE FILE
  // ==============================

  Future<void> delete(
    String id,
  ) async {
    try {
      await _firebase
          .siteFloorFiles
          .doc(id)
          .delete();
    } catch (e) {
      rethrow;
    }
  }
}