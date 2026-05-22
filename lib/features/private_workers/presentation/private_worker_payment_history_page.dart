import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/private_worker_payment_dao.dart';
import '../data/private_worker_payment_model.dart';

class PrivateWorkerPaymentHistoryPage extends StatefulWidget {
  final String workerId;
  final String workerName;
  const PrivateWorkerPaymentHistoryPage({
    super.key,
    required this.workerId,
    required this.workerName,
  });
  @override
  State<PrivateWorkerPaymentHistoryPage> createState() => _State();
}

class _State extends State<PrivateWorkerPaymentHistoryPage> {
  final _dao = PrivateWorkerPaymentDao();
  List<_PaymentEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final client = Supabase.instance.client;

      // 1. Direct payments (cash/online)
      final directPayments = await _dao.getByWorker(widget.workerId);

      // FIX 6: Also fetch payment entries from private_work table
      final workEntries = await client
          .from('private_work')
          .select()
          .eq('worker_id', widget.workerId)
          .gt('amount_paid', 0)
          .order('work_date', ascending: false);

      final List<_PaymentEntry> all = [];

      for (final p in directPayments) {
        all.add(_PaymentEntry(
          date: p.date,
          amount: p.amount,
          isOut: p.direction == 'dad_to_worker',
          label: p.direction == 'dad_to_worker' ? 'Direct Payment' : 'Received from Worker',
          sublabel: '${p.mode}${p.notes != null && p.notes!.isNotEmpty ? ' · ${p.notes}' : ''}',
          type: 'payment',
          id: p.id,
          canDelete: true,
        ));
      }

      for (final w in workEntries) {
        final paid = ((w['amount_paid'] ?? 0) as num).toDouble();
        if (paid <= 0) continue;
        all.add(_PaymentEntry(
          date: w['work_date'] as String? ?? '',
          amount: paid,
          isOut: true,
          label: 'Work Payment — ${w['site_name'] ?? ''}',
          sublabel: w['work_type'] as String? ?? '',
          type: 'work',
          id: w['id'] as String?,
          canDelete: false,
        ));
      }

      // Sort by date descending
      all.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) setState(() { _entries = all; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalOut = _entries.where((e) => e.isOut).fold<double>(0, (s, e) => s + e.amount);
    final totalIn  = _entries.where((e) => !e.isOut).fold<double>(0, (s, e) => s + e.amount);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Payment History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(widget.workerName, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ]),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(children: [
            // Summary bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                _summaryTile('Paid Out', '₹${totalOut.toStringAsFixed(0)}', Colors.green),
                Container(width: 1, height: 36, color: Colors.grey.shade200),
                _summaryTile('Received', '₹${totalIn.toStringAsFixed(0)}', Colors.red),
                Container(width: 1, height: 36, color: Colors.grey.shade200),
                _summaryTile('Balance', '₹${(totalOut - totalIn).abs().toStringAsFixed(0)}',
                  totalOut >= totalIn ? Colors.green : Colors.red),
              ]),
            ),
            const Divider(height: 1),

            Expanded(
              child: _entries.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('No payment history', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                  ]))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _entries.length,
                      itemBuilder: (_, i) {
                        final e = _entries[i];
                        final color = e.isOut ? Colors.green : Colors.red;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.1), radius: 20,
                              child: Icon(
                                e.type == 'work'
                                  ? Icons.construction_rounded
                                  : (e.isOut ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded),
                                color: color, size: 18)),
                            title: Row(children: [
                              Text('₹${e.amount.toStringAsFixed(0)}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(e.label,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                            ]),
                            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              if (e.sublabel.isNotEmpty)
                                Text(e.sublabel, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                              Text(e.date, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            ]),
                            trailing: e.canDelete && e.id != null
                              ? IconButton(
                                  icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                                  onPressed: () async {
                                    await _dao.delete(e.id!);
                                    _load();
                                  },
                                )
                              : const SizedBox.shrink(),
                          ),
                        );
                      },
                    ),
                  ),
            ),
          ]),
    );
  }

  Widget _summaryTile(String label, String value, Color color) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
  ]));
}

class _PaymentEntry {
  final String date, label, sublabel, type;
  final double amount;
  final bool isOut, canDelete;
  final String? id;
  const _PaymentEntry({
    required this.date, required this.amount, required this.isOut,
    required this.label, required this.sublabel, required this.type,
    this.id, required this.canDelete,
  });
}
