import '../../../core/services/supabase_service.dart';

import 'private_work_model.dart';

class PrivateWorkDao {

  final SupabaseService _supabase =
      SupabaseService.instance;

  // =========================
  // GET ALL
  // =========================

  Future<List<PrivateWork>>
      getAll() async {

    try {

      final response =
          await _supabase.privateWork
              .select()
              .order(
                'created_at',
                ascending: false,
              );

      return (response as List)
          .map((e) {

        return PrivateWork.fromMap(
          e,
          e['id'].toString(),
        );

      }).toList();

    } catch (e) {

      return [];
    }
  }

  // =========================
  // INSERT
  // =========================

  Future<void> insert(
    PrivateWork work,
  ) async {

    await _supabase.privateWork
        .insert(
          work.toMap(),
        );
  }

  // =========================
  // UPDATE
  // =========================

  Future<void> update(
    PrivateWork work,
  ) async {

    if (work.id == null) {
      return;
    }

    await _supabase.privateWork
        .update(
          work.toMap(),
        )
        .eq(
          'id',
          work.id!,
        );
  }

  // =========================
  // DELETE
  // =========================

  Future<void> delete(
    String id,
  ) async {

    await _supabase.privateWork
        .delete()
        .eq(
          'id',
          id,
        );
  }
}