import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/worker_dao.dart';
import '../data/worker_model.dart';
import 'add_worker_page.dart';

class WorkerDetailsPage extends StatelessWidget {
  final WorkerModel worker;
  const WorkerDetailsPage({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(worker.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () async {
            final changed = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddWorkerPage(worker: worker)));
            if (changed == true && context.mounted) Navigator.pop(context, true);
          }),
        ],
      ),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          // Profile header
          Card(child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              CircleAvatar(
                radius: 36, backgroundColor: cs.primaryContainer,
                child: Text(worker.name[0].toUpperCase(),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: cs.onPrimaryContainer)),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(worker.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: [
                  _badge(worker.workType, cs.primaryContainer, cs.onPrimaryContainer),
                  const SizedBox(width: 8),
                  _badge(worker.role, Colors.grey.shade200, Colors.grey.shade800),
                ]),
              ])),
              if (worker.phone.isNotEmpty)
                FloatingActionButton.small(
                  heroTag: 'call',
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.call_rounded, color: Colors.white),
                  onPressed: () => launchUrl(Uri.parse('tel:${worker.phone}')),
                ),
            ]),
          )),
          const SizedBox(height: 12),

          // Details
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _infoRow(Icons.phone_rounded, 'Phone', worker.phone, context),
              _infoRow(Icons.person_rounded, 'Gender', worker.gender, context),
              _infoRow(Icons.location_on_rounded, 'State', worker.state, context),
              _infoRow(Icons.work_rounded, 'Work Type', worker.workType, context),
              _infoRow(Icons.construction_rounded, 'Role', worker.role, context),
              if (worker.notes != null && worker.notes!.isNotEmpty)
                _infoRow(Icons.notes_rounded, 'Notes', worker.notes!, context),
            ]),
          )),
          const SizedBox(height: 12),

          // Wages
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.currency_rupee, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                const Text('Wage Rates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 12),
              _wageRow('6 AM – 6 PM', worker.rate6to6, context),
              _wageRow('10 AM – 6 PM', worker.rate10to6, context),
              _wageRow('6 AM – 10 PM', worker.rate6to10, context),
              _wageRow('6 AM – 2 PM', worker.rate6to2, context),
              _wageRow('10 AM – 2 PM', worker.rate10to2, context),
              _wageRow('2 PM – 6 PM', worker.rate2to6, context),
            ]),
          )),
          const SizedBox(height: 12),

          // Delete
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_rounded, color: Colors.red),
            label: const Text('Delete Worker', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
            onPressed: () async {
              final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
                title: const Text('Delete Worker'),
                content: Text('Delete ${worker.name}? This cannot be undone.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('Delete'),
                  ),
                ],
              ));
              if (confirm == true && worker.id != null) {
                await WorkerDao().deleteWorker(worker.id!);
                if (context.mounted) Navigator.pop(context, true);
              }
            },
          ),
          const SizedBox(height: 24),
        ]),
      )),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
      ]),
    );
  }

  Widget _wageRow(String shift, double amount, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(child: Text(shift, style: const TextStyle(fontSize: 14))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(8)),
          child: Text('₹${amount.toStringAsFixed(0)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: cs.onPrimaryContainer)),
        ),
      ]),
    );
  }

  Widget _badge(String label, Color bg, Color text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: TextStyle(fontSize: 12, color: text, fontWeight: FontWeight.w500)),
  );
}
