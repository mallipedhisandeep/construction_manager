import 'package:flutter/material.dart';
import '../data/private_worker_payment_dao.dart';
import '../data/private_worker_payment_model.dart';

class PrivateWorkerPaymentHistoryPage extends StatefulWidget {
  final String workerId;
  const PrivateWorkerPaymentHistoryPage({super.key, required this.workerId});
  @override
  State<PrivateWorkerPaymentHistoryPage> createState() => _State();
}

class _State extends State<PrivateWorkerPaymentHistoryPage> {
  final _dao = PrivateWorkerPaymentDao();
  List<PrivateWorkerPayment> _payments = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final p = await _dao.getByWorker(widget.workerId);
      if (mounted) setState(() { _payments = p; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Payment History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _payments.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('No payment history', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
            ]))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _payments.length,
                itemBuilder: (_, i) {
                  final p = _payments[i];
                  final isOut = p.direction == 'dad_to_worker';
                  final color = isOut ? Colors.green : Colors.red;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.1),
                        child: Icon(isOut ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          color: color, size: 20),
                      ),
                      title: Row(children: [
                        Text('₹${p.amount.toStringAsFixed(0)}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: color)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                          child: Text(p.mode, style: TextStyle(fontSize: 11, color: Colors.grey.shade700))),
                      ]),
                      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(isOut ? 'You → Worker' : 'Worker → You',
                          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
                        Text(p.date, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        if (p.notes != null && p.notes!.trim().isNotEmpty)
                          Text(p.notes!, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                        onPressed: () async {
                          await _dao.delete(p.id!);
                          _load();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
