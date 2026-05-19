import 'package:cloud_firestore/cloud_firestore.dart';

import 'private_work_model.dart';

class PrivateWorkDao {
  final _firestore =
      FirebaseFirestore.instance;

  final _collection =
      FirebaseFirestore.instance
          .collection('private_work');

  Future<List<PrivateWork>> getAll() async {
    final snapshot =
        await _collection
            .orderBy(
              'createdAt',
              descending: true,
            )
            .get();

    return snapshot.docs
        .map(
          (e) => PrivateWork.fromMap(
            e.data(),
            e.id,
          ),
        )
        .toList();
  }

  Future<void> insert(
    PrivateWork work,
  ) async {
    await _collection.add(
      work.toMap(),
    );
  }

  Future<void> update(
    PrivateWork work,
  ) async {
    await _collection
        .doc(work.id)
        .update(
          work.toMap(),
        );
  }

  Future<void> delete(
    String id,
  ) async {
    await _collection.doc(id).delete();
  }
}