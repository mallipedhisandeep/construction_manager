import 'package:cloud_firestore/cloud_firestore.dart';

import 'private_worker_model.dart';

class PrivateWorkerDao {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final String collection = 'private_workers';

  // ================= GET ALL =================

  Future<List<PrivateWorker>> getAll() async {
    final snapshot = await _firestore
        .collection(collection)
        .orderBy('name')
        .get();

    return snapshot.docs.map((doc) {
      return PrivateWorker.fromMap(
        doc.data(),
        doc.id,
      );
    }).toList();
  }

  // ================= INSERT =================

  Future<void> insert(PrivateWorker worker) async {
    await _firestore.collection(collection).add(
          worker.toMap(),
        );
  }

  // ================= UPDATE =================

  Future<void> update(PrivateWorker worker) async {
    await _firestore
        .collection(collection)
        .doc(worker.id)
        .update(worker.toMap());
  }

  // ================= DELETE =================

  Future<void> delete(String id) async {
    await _firestore
        .collection(collection)
        .doc(id)
        .delete();
  }

  // ================= SUMMARY =================

  Future<PrivateWorkerSummary> getSummary(
    String workerId,
  ) async {
    final workSnapshot = await _firestore
        .collection('private_work')
        .where('worker_id', isEqualTo: workerId)
        .get();

    final paymentSnapshot = await _firestore
        .collection('private_worker_payments')
        .where('worker_id', isEqualTo: workerId)
        .get();

    String? lastSite;
    String? lastDate;

    double balance = 0;

    // ===== PRIVATE WORK =====

    for (final doc in workSnapshot.docs) {
      final data = doc.data();

      final charged =
          (data['price_charged'] ?? 0).toDouble();

      final paid =
          (data['amount_paid'] ?? 0).toDouble();

      balance += charged;
      balance -= paid;

      lastSite = data['site_name'];
      lastDate = data['work_date'];
    }

    // ===== PAYMENTS =====

    for (final doc in paymentSnapshot.docs) {
      final data = doc.data();

      final amount =
          (data['amount'] ?? 0).toDouble();

      if (data['direction'] == 'dad_to_worker') {
        balance -= amount;
      } else {
        balance += amount;
      }
    }

    return PrivateWorkerSummary(
      lastSite: lastSite,
      lastDate: lastDate,
      balance: balance,
    );
  }
}

class PrivateWorkerSummary {
  final String? lastSite;
  final String? lastDate;
  final double balance;

  PrivateWorkerSummary({
    this.lastSite,
    this.lastDate,
    required this.balance,
  });
}