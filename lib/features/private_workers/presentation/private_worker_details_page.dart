import 'package:flutter/material.dart';
import '../data/private_worker_model.dart';
import '../data/private_worker_dao.dart';
import '../data/private_worker_payment_dao.dart';
import '../data/private_worker_payment_model.dart';
import 'private_worker_payment_history_page.dart';
import 'add_edit_private_worker_page.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivateWorkerDetailsPage extends StatefulWidget {
  final PrivateWorker worker;
  const PrivateWorkerDetailsPage({super.key, required this.worker});

  @override
  State<PrivateWorkerDetailsPage> createState() =>
      _PrivateWorkerDetailsPageState();
}

class _PrivateWorkerDetailsPageState extends State<PrivateWorkerDetailsPage> {
  final _dao = PrivateWorkerDao();
  final _paymentDao = PrivateWorkerPaymentDao();

  PrivateWorkerSummary? summary;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    summary = await _dao.getSummary(widget.worker.id!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (summary == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.worker.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteWorker,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Work: ${widget.worker.workType}'),
            Row(
              children: [
                Text('Phone: ${widget.worker.phone}'),
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () =>
                      launchUrl(Uri.parse('tel:${widget.worker.phone}')),
                )
              ],
            ),
            Text('Last Site: ${summary!.lastSite ?? '-'}'),
            Text('Last Date: ${summary!.lastDate ?? '-'}'),
            const SizedBox(height: 8),
            Text(
              summary!.balance == 0
                  ? 'Balance Settled'
                  : summary!.balance > 0
                  ? 'Dad should give ₹${summary!.balance}'
                  : 'Worker should give ₹${summary!.balance.abs()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: summary!.balance == 0
                    ? Colors.grey
                    : summary!.balance > 0
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final ok = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddEditPrivateWorkerPage(worker: widget.worker),
                  ),
                );
                if (ok == true) load();
              },
              child: const Text('Edit'),
            ),

            ElevatedButton(
              onPressed: addPayment,
              child: const Text('Payment'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrivateWorkerPaymentHistoryPage(
                        workerId: widget.worker.id!),
                  ),
                );
              },
              child: const Text('History'),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> addPayment() async {
    double amount = 0;
    String direction = 'dad_to_worker';
    String mode = 'Cash';
    final noteCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
              onChanged: (v) => amount = double.tryParse(v) ?? 0,
            ),
            DropdownButtonFormField(
              value: direction,
              items: const [
                DropdownMenuItem(
                    value: 'dad_to_worker', child: Text('Dad → Worker')),
                DropdownMenuItem(
                    value: 'worker_to_dad', child: Text('Worker → Dad')),
              ],
              onChanged: (v) => direction = v!,
              decoration:
              const InputDecoration(labelText: 'Payment By'),
            ),
            DropdownButtonFormField(
              value: mode,
              items: const ['Cash', 'Online']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => mode = v!,
              decoration: const InputDecoration(labelText: 'Mode'),
            ),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (amount <= 0) return;

              await _paymentDao.insert(
                PrivateWorkerPayment(
                  workerId: widget.worker.id!,
                  amount: amount,
                  direction: direction,
                  mode: mode,
                  date: DateTime.now().toIso8601String().split('T')[0],
                  source: 'manual',
                  notes: noteCtrl.text,
                ),
              );

              Navigator.pop(context);
              await load();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteWorker() async {
    await _dao.delete(widget.worker.id!);
    Navigator.pop(context, true);
  }
}