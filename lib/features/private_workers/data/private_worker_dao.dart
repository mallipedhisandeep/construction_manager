import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
      debugPrint(
        'GET PRIVATE WORKERS ERROR => $e',
      );

      return [];
    }
  }

  // =========================
  // INSERT
  // =========================

  Future<void> insert(
    PrivateWorker worker,
  ) async {
    try {
      await _collection.add(
        worker.toMap(),
      );
    } catch (e) {
      debugPrint(
        'INSERT PRIVATE WORKER ERROR => $e',
      );

      rethrow;
    }
  }

  // =========================
  // UPDATE
  // =========================

  Future<void> update(
    PrivateWorker worker,
  ) async {
    try {
      if (worker.id == null) {
        return;
      }

      await _collection
          .doc(worker.id)
          .update(
            worker.toMap(),
          );
    } catch (e) {
      debugPrint(
        'UPDATE PRIVATE WORKER ERROR => $e',
      );

      rethrow;
    }
  }

  // =========================
  // DELETE
  // =========================

  Future<void> delete(
    String id,
  ) async {
    try {
      await _collection
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint(
        'DELETE PRIVATE WORKER ERROR => $e',
      );

      rethrow;
    }
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
            ((data['price_charged'] ??
                        0)
                    as num)
                .toDouble();

        totalPaid +=
            ((data['amount_paid'] ??
                        0)
                    as num)
                .toDouble();

        lastSite =
            data['site_name']
                ?.toString();

        lastDate =
            data['work_date']
                ?.toString();
      }

      for (final doc
          in paymentSnapshot.docs) {
        final data =
            doc.data();

        final amount =
            ((data['amount'] ?? 0)
                    as num)
                .toDouble();

        final direction =
            data['direction']
                ?.toString();

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
      debugPrint(
        'PRIVATE WORKER SUMMARY ERROR => $e',
      );

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