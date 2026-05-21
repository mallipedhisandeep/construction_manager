import '../../../core/services/supabase_service.dart';

import 'worker_model.dart';

class WorkerDao {

  final SupabaseService _supabase =
      SupabaseService.instance;

  // =========================
  // ADD WORKER
  // =========================

  Future<void> insertWorker(
    WorkerModel worker,
  ) async {

    await _supabase.workers.insert(
      worker.toMap(),
    );
  }

  // =========================
  // WATCH WORKERS
  // =========================

  Stream<List<WorkerModel>>
      watchWorkers() async* {

    while (true) {

      final response =
          await _supabase.workers
              .select()
              .order(
                'work_type',
              )
              .order(
                'state',
              )
              .order(
                'role',
              )
              .order(
                'name',
              );

      yield (response as List)
          .map((item) {

        return WorkerModel.fromMap(
          item,
          item['id'].toString(),
        );

      }).toList();

      await Future.delayed(
        const Duration(seconds: 2),
      );
    }
  }

  // =========================
  // GET ALL WORKERS
  // =========================

  Future<List<WorkerModel>>
      getAllWorkers() async {

    final response =
        await _supabase.workers
            .select()
            .order(
              'work_type',
            )
            .order(
              'state',
            )
            .order(
              'role',
            )
            .order(
              'name',
            );

    return (response as List)
        .map((item) {

      return WorkerModel.fromMap(
        item,
        item['id'].toString(),
      );

    }).toList();
  }

  // =========================
  // UPDATE
  // =========================

  Future<void> updateWorker(
    WorkerModel worker,
  ) async {

    await _supabase.workers
        .update(
          worker.toMap(),
        )
        .eq(
          'id',
          worker.id!,
        );
  }

  // =========================
  // DELETE
  // =========================

  Future<void> deleteWorker(
    String id,
  ) async {

    await _supabase.workers
        .delete()
        .eq(
          'id',
          id,
        );
  }
}