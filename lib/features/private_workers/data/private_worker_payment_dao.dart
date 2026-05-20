import '../../../core/services/firebase_service.dart';

import 'private_worker_payment_model.dart';

class PrivateWorkerPaymentDao {
  final FirebaseService _firebase =
      FirebaseService.instance;

  // ==============================
  // COLLECTION
  // ==============================

  dynamic get _collection =>
      _firebase.privateWorkerPayments;

  // ==============================
  // INSERT
  // ==============================

  Future<void> insert(
    PrivateWorkerPayment payment,
  ) async {
    await _collection.add(
      payment.toMap(),
    );
  }

  // ==============================
  // GET BY WORKER
  // ==============================

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
          (doc) =>
              PrivateWorkerPayment
                  .fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  }

  // ==============================
  // DELETE
  // ==============================

  Future<void> delete(
    String id,
  ) async {
    await _collection
        .doc(id)
        .delete();
  }
}