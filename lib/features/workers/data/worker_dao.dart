import '../../../core/services/firebase_service.dart';

import 'worker_model.dart';

class WorkerDao {
  final FirebaseService _firebase =
      FirebaseService.instance;

  // =========================
  // ADD WORKER
  // =========================

  Future<void> insertWorker(
    WorkerModel worker,
  ) async {
    await _firebase.workers.add(
      worker.toMap(),
    );
  }

  // =========================
  // REALTIME WORKERS STREAM
  // =========================

  Stream<List<WorkerModel>>
      watchWorkers() {
    return _firebase.workers

        .orderBy('work_type')

        .orderBy('state')

        .orderBy('role')

        .orderBy('name')

        .snapshots()

        .map((snapshot) {
      return snapshot.docs.map((
        doc,
      ) {
        return WorkerModel.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  // =========================
  // GET ALL WORKERS
  // =========================

  Future<List<WorkerModel>>
      getAllWorkers() async {
    final snapshot =
        await _firebase.workers

            .orderBy(
              'work_type',
            )

            .orderBy(
              'state',
            )

            .orderBy(
              'role',
            )

            .orderBy(
              'name',
            )

            .get();

    return snapshot.docs.map((
      doc,
    ) {
      return WorkerModel.fromMap(
        doc.data(),
        doc.id,
      );
    }).toList();
  }

  // =========================
  // UPDATE
  // =========================

  Future<void> updateWorker(
    WorkerModel worker,
  ) async {
    await _firebase.workers
        .doc(worker.id)
        .update(
          worker.toMap(),
        );
  }

  // =========================
  // DELETE
  // =========================

  Future<void> deleteWorker(
    String id,
  ) async {
    await _firebase.workers
        .doc(id)
        .delete();
  }
}