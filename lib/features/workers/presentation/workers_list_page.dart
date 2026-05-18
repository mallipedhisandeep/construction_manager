import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/worker_dao.dart';
import '../data/worker_model.dart';
import 'add_worker_page.dart';
import 'worker_details_page.dart';

class WorkersListPage extends StatefulWidget {
  const WorkersListPage({super.key});

  @override
  State<WorkersListPage> createState() => _WorkersListPageState();
}

class _WorkersListPageState extends State<WorkersListPage> {
  final WorkerDao _dao = WorkerDao();
  List<WorkerModel> workers = [];

  @override
  void initState() {
    super.initState();
    loadWorkers();
  }

  Future<void> loadWorkers() async {
    final data = await _dao.getAllWorkers();
    setState(() {
      workers = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workers')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddWorkerPage()),
          );
          if (result == true) {
            loadWorkers();
          }
        },
      ),
      body: workers.isEmpty
          ? const Center(child: Text('No workers added'))
          : ListView.builder(
        itemCount: workers.length,
        itemBuilder: (context, index) {
          final worker = workers[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(worker.name),
              subtitle: Text(
                '${worker.workType} • ${worker.state} • ${worker.role}',
              ),

              // 👇 RIGHT SIDE ICONS
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 📞 CALL ICON
                  if (worker.phone.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.call, color: Colors.green),
                      onPressed: () {
                        final uri = Uri.parse('tel:${worker.phone}');
                        launchUrl(uri);
                      },
                    ),

                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkerDetailsPage(worker: worker),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

