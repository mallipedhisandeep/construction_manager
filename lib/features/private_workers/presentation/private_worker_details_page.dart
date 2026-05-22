import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/private_worker_dao.dart';
import '../data/private_worker_model.dart';
import '../data/private_worker_payment_dao.dart';
import '../data/private_worker_payment_model.dart';
import 'add_edit_private_worker_page.dart';
import 'private_worker_payment_history_page.dart';

class PrivateWorkerDetailsPage extends StatefulWidget {
  final PrivateWorker worker;
  const PrivateWorkerDetailsPage({super.key, required this.worker});
  @override
  State<PrivateWorkerDetailsPage> createState() => _PrivateWorkerDetailsPageState();
}

class _PrivateWorkerDetailsPageState extends State<PrivateWorkerDetailsPage> {
  final _dao = PrivateWorkerDao();
  final _payDao = PrivateWorkerPaymentDao();
  PrivateWorkerSummary? _summary;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final s = await _dao.getSummary(widget.worker.id!);
      if (mounted) setState(() { _summary = s; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final balance = _summary?.balance ?? 0;
    final balanceColor = balance > 0 ? Colors.green : balance < 0 ? Colors.red : Colors.grey;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.worker.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () async {
            final ok = await Navigator.push(context, MaterialPageRoute(
              builder: (_) => AddEditPrivateWorkerPage(worker: widget.worker)));
            if (ok == true) _load();
          }),
          IconButton(icon: const Icon(Icons.delete_rounded), onPressed: _delete),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(padding: const EdgeInsets.all(16), children: [
            // Profile + Balance
            Card(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(children: [
                  CircleAvatar(
                    radius: 30, backgroundColor: cs.primaryContainer,
                    child: Text(widget.worker.name[0].toUpperCase(),
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onPrimaryContainer)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.worker.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(widget.worker.workType, style: TextStyle(color: Colors.grey.shade600)),
                    if (widget.worker.phone.isNotEmpty) GestureDetector(
                      onTap: () => launchUrl(Uri.parse('tel:${widget.worker.phone}')),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.call_rounded, size: 14, color: Colors.green.shade600),
                        const SizedBox(width: 4),
                        Text(widget.worker.phone, style: TextStyle(fontSize: 13, color: Colors.green.shade700)),
                      ]),
                    ),
                  ])),
                ]),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: balanceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: balanceColor.withOpacity(0.3))),
                  child: Column(children: [
                    Text('Balance', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Text(
                      balance == 0 ? 'All Settled ✓'
                        : balance > 0 ? '₹${balance.toStringAsFixed(0)}\nOwed to worker'
                        : '₹${balance.abs().toStringAsFixed(0)}\nWorker owes you',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: balanceColor)),
                  ]),
                ),
              ]),
            )),
            const SizedBox(height: 12),

            if (_summary?.lastSite != null) Card(child: ListTile(
              leading: Icon(Icons.location_on_rounded, color: cs.primary),
              title: const Text('Last Site', style: TextStyle(fontSize: 13, color: Colors.grey)),
              subtitle: Text(_summary!.lastSite!, style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: _summary?.lastDate != null ? Text(_summary!.lastDate!,
                style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
            )),
            const SizedBox(height: 12),

            // Actions
            Row(children: [
              Expanded(child: ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Payment'),
                style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white),
                onPressed: _addPayment,
              )),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(
                icon: const Icon(Icons.history_rounded),
                label: const Text('History'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PrivateWorkerPaymentHistoryPage(
                    workerId: widget.worker.id!,
                    workerName: widget.worker.name,
                  ))),
              )),
            ]),
            const SizedBox(height: 24),
          ]),
    );
  }

  Future<void> _addPayment() async {
    double amount = 0;
    String direction = 'dad_to_worker';
    String mode = 'Cash';
    final noteCtrl = TextEditingController();

    await showDialog(context: context, builder: (_) => StatefulBuilder(
      builder: (ctx, setSt) => AlertDialog(
        title: const Text('Add Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (₹)', prefixText: '₹ '),
            onChanged: (v) => amount = double.tryParse(v) ?? 0,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: direction,
            decoration: const InputDecoration(labelText: 'Direction'),
            items: const [
              DropdownMenuItem(value: 'dad_to_worker', child: Text('You → Worker')),
              DropdownMenuItem(value: 'worker_to_dad', child: Text('Worker → You')),
            ],
            onChanged: (v) { if (v != null) setSt(() => direction = v); },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: mode,
            decoration: const InputDecoration(labelText: 'Mode'),
            items: ['Cash','Online'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) { if (v != null) setSt(() => mode = v); },
          ),
          const SizedBox(height: 12),
          TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
            child: const Text('Save'),
            onPressed: () async {
              if (amount <= 0) return;
              await _payDao.insert(PrivateWorkerPayment(
                workerId: widget.worker.id!, amount: amount,
                direction: direction, mode: mode,
                date: DateTime.now().toIso8601String().split('T').first,
                source: 'manual', notes: noteCtrl.text.trim(), createdAt: DateTime.now()));
              if (context.mounted) {
                Navigator.pop(context);
                await _load();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment added!'), backgroundColor: Colors.green));
              }
            },
          ),
        ],
      ),
    ));
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Delete Worker'),
      content: Text('Delete ${widget.worker.name}? This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Delete'),
        ),
      ],
    ));
    if (confirm == true) {
      await _dao.delete(widget.worker.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }
}
