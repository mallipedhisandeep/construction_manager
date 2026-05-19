import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firebase_service.dart';
import 'worker_model.dart';

class WorkerDao {
  final FirebaseService _firebase =
      FirebaseService.instance;

  // ==============================
  // ADD WORKER
  // ==============================

  Future<void> insertWorker(
    WorkerModel worker,
  ) async {
    await _firebase.workers.add(worker.toMap());
  }

  // ==============================
  // GET ALL WORKERS
  // ==============================

  Future<List<WorkerModel>> getAllWorkers() async {
    final snapshot = await _firebase.workers
        .orderBy('work_type')
        .orderBy('state')
        .orderBy('role')
        .orderBy('name')
        .get();

    return snapshot.docs.map((doc) {
      return WorkerModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  // ==============================
  // UPDATE WORKER
  // ==============================

  Future<void> updateWorker(
    WorkerModel worker,
  ) async {
    await _firebase.workers
        .doc(worker.id)
        .update(worker.toMap());
  }

  // ==============================
  // DELETE WORKER
  // ==============================

  Future<void> deleteWorker(
    String id,
  ) async {
    await _firebase.workers
        .doc(id)
        .delete();
  }
}