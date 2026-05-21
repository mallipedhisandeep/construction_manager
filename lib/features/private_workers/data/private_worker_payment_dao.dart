import '../../../core/services/supabase_service.dart';

import 'private_worker_payment_model.dart';

class PrivateWorkerPaymentDao {

  final SupabaseService _supabase =
      SupabaseService.instance;

  dynamic get _collection =>
      _supabase.privateWorkerPayments;

  // ==============================
  // INSERT
  // ==============================

  Future<void> insert(
    PrivateWorkerPayment payment,
  ) async {

    await _collection.insert(
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

    final response =
        await _collection
            .select()
            .eq(
              'workerId',
              workerId,
            )
            .order(
              'createdAt',
              ascending: false,
            );

    return (response as List)
        .map(
      (doc) {

        return PrivateWorkerPayment
            .fromMap(
          doc,
          doc['id'].toString(),
        );
      },
    ).toList();
  }

  // ==============================
  // DELETE
  // ==============================

  Future<void> delete(
    String id,
  ) async {

    await _collection
        .delete()
        .eq(
          'id',
          id,
        );
  }
}