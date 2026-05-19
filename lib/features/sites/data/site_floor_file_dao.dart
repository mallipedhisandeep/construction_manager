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
          await _firebase.siteFloorFiles

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

      final files =
          snapshot.docs.map(
        (doc) {

          return SiteFloorFileModel
              .fromMap(

            doc.data()
                as Map<String, dynamic>,

            doc.id,
          );
        },
      ).toList();

      return files;

    } catch (e) {

      print(
        'GET FLOOR FILES ERROR => $e',
      );

      return [];
    }
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
          await _firebase.siteFloorFiles

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

      print(
        'COUNT FILES ERROR => $e',
      );

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

      await _firebase.siteFloorFiles
          .add(
        model.toMap(),
      );

      print(
        'FLOOR FILE INSERTED',
      );

    } catch (e) {

      print(
        'INSERT FLOOR FILE ERROR => $e',
      );
    }
  }

  // ==============================
  // DELETE FILE
  // ==============================

  Future<void> delete(
    String id,
  ) async {

    try {

      await _firebase.siteFloorFiles
          .doc(id)
          .delete();

      print(
        'FLOOR FILE DELETED',
      );

    } catch (e) {

      print(
        'DELETE FLOOR FILE ERROR => $e',
      );
    }
  }
}