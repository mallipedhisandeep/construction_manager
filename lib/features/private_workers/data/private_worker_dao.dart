import 'package:cloud_firestore/cloud_firestore.dart';

import 'private_worker_model.dart';

class PrivateWorkerDao {
  final _collection =
      FirebaseFirestore.instance.collection(
    'private_workers',
  );

  final _workCollection =
      FirebaseFirestore.instance.collection(
    'private_work',
  );

  final _paymentCollection =
      FirebaseFirestore.instance.collection(
    'private_worker_payments',
  );

  Future<List<PrivateWorker>> getAll() async {
    final snapshot = await _collection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .get();

    return snapshot.docs
        .map(
          (e) => PrivateWorker.fromMap(
            e.data(),
            e.id,
          ),
        )
        .toList();
  }

  Future<void> insert(
    PrivateWorker worker,
  ) async {
    await _collection.add(
      worker.toMap(),
    );
  }

  Future<void> update(
    PrivateWorker worker,
  ) async {
    await _collection
        .doc(worker.id)
        .update(
          worker.toMap(),
        );
  }

  Future<void> delete(
    String id,
  ) async {
    await _collection.doc(id).delete();
  }

  // ================= SUMMARY =================

  Future<PrivateWorkerSummary> getSummary(
    String workerId,
  ) async {
    final workSnapshot =
        await _workCollection
            .where(
              'workerId',
              isEqualTo: workerId,
            )
            .get();

    final paymentSnapshot =
        await _paymentCollection
            .where(
              'workerId',
              isEqualTo: workerId,
            )
            .get();

    double totalCharged = 0;
    double totalPaid = 0;

    String? lastSite;
    String? lastDate;

    for (final doc in workSnapshot.docs) {
      final data = doc.data();

      totalCharged +=
          (data['priceCharged'] ?? 0)
              .toDouble();

      totalPaid +=
          (data['amountPaid'] ?? 0)
              .toDouble();

      lastSite =
          data['siteName'];

      lastDate =
          data['workDate'];
    }

    for (final doc
        in paymentSnapshot.docs) {
      final data = doc.data();

      final amount =
          (data['amount'] ?? 0)
              .toDouble();

      final direction =
          data['direction'];

      if (direction ==
          'dad_to_worker') {
        totalPaid += amount;
      } else {
        totalCharged += amount;
      }
    }

    return PrivateWorkerSummary(
      lastSite: lastSite,
      lastDate: lastDate,
      balance:
          totalCharged - totalPaid,
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