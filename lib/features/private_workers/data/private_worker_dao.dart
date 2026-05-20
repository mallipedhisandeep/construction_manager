import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firebase_service.dart';

import 'private_worker_model.dart';

class PrivateWorkerDao {
  // =========================
  // COLLECTIONS
  // =========================

  final CollectionReference<
          Map<String, dynamic>>
      _collection =
      FirebaseService.instance
          .privateWorkers;

  final CollectionReference<
          Map<String, dynamic>>
      _workCollection =
      FirebaseService.instance
          .privateWork;

  final CollectionReference<
          Map<String, dynamic>>
      _paymentCollection =
      FirebaseService.instance
          .privateWorkerPayments;

  // =========================
  // GET ALL
  // =========================

  Future<List<PrivateWorker>>
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
                PrivateWorker.fromMap(
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
    PrivateWorker worker,
  ) async {
    await _collection.add(
      worker.toMap(),
    );
  }

  // =========================
  // UPDATE
  // =========================

  Future<void> update(
    PrivateWorker worker,
  ) async {
    if (worker.id == null) {
      return;
    }

    await _collection
        .doc(worker.id)
        .update(
          worker.toMap(),
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

  // =========================
  // SUMMARY
  // =========================

  Future<PrivateWorkerSummary>
      getSummary(
    String workerId,
  ) async {
    try {
      final workSnapshot =
          await _workCollection
              .where(
                'worker_id',
                isEqualTo:
                    workerId,
              )
              .get();

      final paymentSnapshot =
          await _paymentCollection
              .where(
                'worker_id',
                isEqualTo:
                    workerId,
              )
              .get();

      double totalCharged = 0;

      double totalPaid = 0;

      String? lastSite;

      String? lastDate;

      for (final doc
          in workSnapshot.docs) {
        final data =
            doc.data();

        totalCharged +=
            (data['price_charged'] ??
                    0)
                .toDouble();

        totalPaid +=
            (data['amount_paid'] ??
                    0)
                .toDouble();

        lastSite =
            data['site_name'];

        lastDate =
            data['work_date'];
      }

      for (final doc
          in paymentSnapshot.docs) {
        final data =
            doc.data();

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
            totalCharged -
                totalPaid,
      );
    } catch (e) {
      return PrivateWorkerSummary(
        balance: 0,
      );
    }
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