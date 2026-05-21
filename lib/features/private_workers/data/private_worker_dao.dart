import 'package:flutter/foundation.dart';
import '../../../core/services/supabase_service.dart';
import 'private_worker_model.dart';

class PrivateWorkerDao {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<List<PrivateWorker>> getAll() async {
    final response = await _supabase.privateWorkers
        .select()
        .order('created_at', ascending: false);
    return response
        .map<PrivateWorker>((e) => PrivateWorker.fromMap(e, e['id'].toString()))
        .toList();
  }

  Future<void> insert(PrivateWorker worker) async {
    // No try/catch — let errors propagate to UI for display
    await _supabase.privateWorkers.insert(worker.toMap());
  }

  Future<void> update(PrivateWorker worker) async {
    if (worker.id == null) return;
    await _supabase.privateWorkers.update(worker.toMap()).eq('id', worker.id!);
  }

  Future<void> delete(String id) async {
    await _supabase.privateWorkers.delete().eq('id', id);
  }

  Future<PrivateWorkerSummary> getSummary(String workerId) async {
    try {
      final workResponse = await _supabase.privateWork
          .select()
          .eq('worker_id', workerId);
      final paymentResponse = await _supabase.privateWorkerPayments
          .select()
          .eq('worker_id', workerId);

      double totalCharged = 0;
      double totalPaid = 0;
      String? lastSite;
      String? lastDate;

      for (final data in workResponse) {
        totalCharged += ((data['price_charged'] ?? 0) as num).toDouble();
        totalPaid    += ((data['amount_paid']    ?? 0) as num).toDouble();
        lastSite = data['site_name'];
        lastDate = data['work_date'];
      }

      for (final data in paymentResponse) {
        final amount    = ((data['amount'] ?? 0) as num).toDouble();
        final direction = data['direction'];
        if (direction == 'dad_to_worker') {
          totalPaid += amount;
        } else {
          totalCharged += amount;
        }
      }

      return PrivateWorkerSummary(
        lastSite: lastSite,
        lastDate: lastDate,
        balance: totalCharged - totalPaid,
      );
    } catch (e) {
      debugPrint('PRIVATE WORKER SUMMARY ERROR => $e');
      return PrivateWorkerSummary(balance: 0);
    }
  }
}

class PrivateWorkerSummary {
  final String? lastSite;
  final String? lastDate;
  final double balance;
  PrivateWorkerSummary({this.lastSite, this.lastDate, required this.balance});
}
