import 'package:cloud_firestore/cloud_firestore.dart';

import 'private_worker_payment_model.dart';

class PrivateWorkerPaymentDao {
  final _collection =
      FirebaseFirestore.instance
          .collection(
    'private_worker_payments',
  );

  Future<void> insert(
    PrivateWorkerPayment p,
  ) async {
    await _collection.add(
      p.toMap(),
    );
  }

  Future<List<PrivateWorkerPayment>>
      getByWorker(
    String workerId,
  ) async {
    final snapshot =
        await _collection
            .where(
              'workerId',
              isEqualTo: workerId,
            )
            .orderBy(
              'createdAt',
              descending: true,
            )
            .get();

    return snapshot.docs
        .map(
          (e) =>
              PrivateWorkerPayment
                  .fromMap(
            e.data(),
            e.id,
          ),
        )
        .toList();
  }
}