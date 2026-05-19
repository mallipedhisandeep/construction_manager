import 'package:cloud_firestore/cloud_firestore.dart';

import 'private_worker_payment_model.dart';

class PrivateWorkerPaymentDao {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final String collection =
      'private_worker_payments';

  // ================= INSERT =================

  Future<void> insert(
    PrivateWorkerPayment payment,
  ) async {
    await _firestore.collection(collection).add(
          payment.toMap(),
        );
  }

  // ================= GET BY WORKER =================

  Future<List<PrivateWorkerPayment>> getByWorker(
    String workerId,
  ) async {
    final snapshot = await _firestore
        .collection(collection)
        .where('worker_id', isEqualTo: workerId)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return PrivateWorkerPayment.fromMap(
        doc.data(),
        doc.id,
      );
    }).toList();
  }

  // ================= BALANCE =================

  Future<double> getBalance(
    String workerId,
  ) async {
    final snapshot = await _firestore
        .collection(collection)
        .where('worker_id', isEqualTo: workerId)
        .get();

    double balance = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final amount =
          (data['amount'] ?? 0).toDouble();

      if (data['direction'] ==
          'dad_to_worker') {
        balance += amount;
      } else {
        balance -= amount;
      }
    }

    return balance;
  }
}