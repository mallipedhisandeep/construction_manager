import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firebase_service.dart';

import 'private_work_model.dart';

class PrivateWorkDao {
  final CollectionReference<
          Map<String, dynamic>>
      _collection =
      FirebaseService.instance
          .privateWork;

  // =========================
  // REALTIME STREAM
  // =========================

  Stream<List<PrivateWork>>
      watchAll() {
    return _collection
        .orderBy(
          'created_at',
          descending: true,
        )
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs
            .map(
              (doc) =>
                  PrivateWork.fromMap(
                doc.data(),
                doc.id,
              ),
            )
            .toList();
      },
    );
  }

  // =========================
  // GET ALL
  // =========================

  Future<List<PrivateWork>>
      getAll() async {
    try {
      final snapshot =
          await _collection
              .orderBy(
                'created_at',
                descending: true,
              )
              .get();

      return snapshot.docs
          .map(
            (e) =>
                PrivateWork.fromMap(
              e.data(),
              e.id,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  // =========================
  // INSERT
  // =========================

  Future<void> insert(
    PrivateWork work,
  ) async {
    await _collection.add(
      work.toMap(),
    );
  }

  // =========================
  // UPDATE
  // =========================

  Future<void> update(
    PrivateWork work,
  ) async {
    if (work.id == null) {
      return;
    }

    await _collection
        .doc(work.id)
        .update(
          work.toMap(),
        );
  }

  // =========================
  // DELETE
  // =========================

  Future<void> delete(
    String id,
  ) async {
    await _collection
        .doc(id)
        .delete();
  }
}