import 'package:flutter/material.dart';
import '../data/worker_model.dart';
import '../data/worker_dao.dart';
import 'add_worker_page.dart';

class WorkerDetailsPage extends StatelessWidget {
  final WorkerModel worker;

  const WorkerDetailsPage({super.key, required this.worker});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              worker.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [

                Text(
                  'Phone Number : ${worker.phone}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),

            const Divider(),

            Text('Gender: ${worker.gender}'),
            Text('State: ${worker.state}'),
            Text('Role: ${worker.role}'),
            Text('Work Type: ${worker.workType}'),

            const SizedBox(height: 16),
            const Text(
              'Wages',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text('6–6 : ₹${worker.rate6to6}'),
            Text('10–6 : ₹${worker.rate10to6}'),
            Text('6–10 : ₹${worker.rate6to10}'),
            Text('6–2 : ₹${worker.rate6to2}'),
            Text('10–2 : ₹${worker.rate10to2}'),
            Text('2–6 : ₹${worker.rate2to6}'),

            if (worker.notes != null && worker.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(worker.notes!),
            ],

            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Edit Worker Details'),
              onPressed: () async {
                final changed = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddWorkerPage(worker: worker),
                  ),
                );
                if (changed == true) {
                  Navigator.pop(context, true);
                }
              },
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              icon: const Icon(Icons.delete),
              label: const Text('Delete Worker'),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Worker'),
                    content: const Text(
                      'Are you sure? This cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await WorkerDao().deleteWorker(worker.id!);
                  Navigator.pop(context, true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}