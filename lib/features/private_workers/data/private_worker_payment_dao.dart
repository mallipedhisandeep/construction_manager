import '../../../core/services/supabase_service.dart';

import 'private_worker_payment_model.dart';

class PrivateWorkerPaymentDao {

  final SupabaseService _supabase =
      SupabaseService.instance;

  // ==============================
  // INSERT
  // ==============================

  Future<void> insert(
    PrivateWorkerPayment payment,
  ) async {
    await _supabase.privateWorkerPayments
        .insert(payment.toMap());
  }

  // ==============================
  // GET BY WORKER
  // FIX: was using camelCase 'workerId' and 'createdAt' — 
  //      must use snake_case column names matching the Supabase table
  // ==============================

  Future<List<PrivateWorkerPayment>> getByWorker(
    String workerId,
  ) async {
    final response = await _supabase.privateWorkerPayments
        .select()
        .eq('worker_id', workerId)
        .order('created_at', ascending: false);

    return (response as List).map((doc) {
      return PrivateWorkerPayment.fromMap(
        doc,
        doc['id'].toString(),
      );
    }).toList();
  }

  // ==============================
  // DELETE
  // ==============================

  Future<void> delete(String id) async {
    await _supabase.privateWorkerPayments
        .delete()
        .eq('id', id);
  }
}
