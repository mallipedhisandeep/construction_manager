import 'package:flutter/material.dart';
import '../data/private_work_dao.dart';
import '../data/private_work_model.dart';
import 'add_edit_private_work_page.dart';

class PrivateWorkDetailsPage extends StatelessWidget {
  final PrivateWork work;
  PrivateWorkDetailsPage({super.key, required this.work});
  final _dao = PrivateWorkDao();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final balance = work.priceCharged - work.amountPaid;
    final isActive = work.status == 'Active';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(work.workerName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () async {
            final ok = await Navigator.push(context, MaterialPageRoute(
              builder: (_) => AddEditPrivateWorkPage(work: work)));
            if (ok == true && context.mounted) Navigator.pop(context, true);
          }),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          _row(context, Icons.construction_rounded, 'Work Type', work.workType),
          _row(context, Icons.location_on_rounded, 'Site', work.siteName),
          _row(context, Icons.calendar_today_rounded, 'Date', work.workDate),
          _row(context, Icons.circle_rounded, 'Status', work.status,
            valueColor: isActive ? Colors.green : Colors.blue),
        ]))),
        const SizedBox(height: 12),

        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          const Text('Payment Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            _moneyCard('Charged', work.priceCharged, Colors.blue, context),
            const SizedBox(width: 8),
            _moneyCard('Paid', work.amountPaid, Colors.green, context),
            const SizedBox(width: 8),
            _moneyCard('Balance', balance, balance > 0 ? Colors.orange : Colors.grey, context),
          ]),
        ]))),

        if (work.notes != null && work.notes!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(Icons.notes_rounded, size: 18, color: cs.primary), const SizedBox(width: 8),
                const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold))]),
              const SizedBox(height: 8),
              Text(work.notes!, style: const TextStyle(height: 1.5)),
            ]))),
        ],
        const SizedBox(height: 24),

        OutlinedButton.icon(
          icon: const Icon(Icons.delete_rounded, color: Colors.red),
          label: const Text('Delete Work Entry', style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
          onPressed: () async {
            final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
              title: const Text('Delete Work Entry'),
              content: const Text('This cannot be undone.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: const Text('Delete')),
              ],
            ));
            if (confirm == true) {
              await _dao.delete(work.id!);
              if (context.mounted) Navigator.pop(context, true);
            }
          },
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: valueColor))),
      ]),
    );
  }

  Widget _moneyCard(String label, double amount, Color color, BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text('₹${amount.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color.shade700)),
      ]),
    ));
  }
}
