import 'package:flutter/material.dart';
import '../data/private_worker_dao.dart';
import '../data/private_worker_model.dart';
import 'add_edit_private_worker_page.dart';
import 'private_worker_details_page.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivateWorkersListPage extends StatefulWidget {
  const PrivateWorkersListPage({super.key});

  @override
  State<PrivateWorkersListPage> createState() =>
      _PrivateWorkersListPageState();
}

class _PrivateWorkersListPageState extends State<PrivateWorkersListPage> {
  final _dao = PrivateWorkerDao();
  List<PrivateWorker> workers = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    workers = await _dao.getAll();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Private Workers')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final ok = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditPrivateWorkerPage()),
          );
          if (ok == true) load();
        },
      ),
      body: ListView.builder(
        itemCount: workers.length,
        itemBuilder: (_, i) {
          final w = workers[i];
          return Card(
            child: ListTile(
              title: Text(w.name),
              subtitle: Text(w.workType),
              trailing: IconButton(
                icon: const Icon(Icons.call),
                onPressed: () {
                  launchUrl(Uri.parse('tel:${w.phone}'));
                },
              ),
              onTap: () async {
                final changed = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrivateWorkerDetailsPage(worker: w),
                  ),
                );
                if (changed == true) load();
              },
            ),
          );
        },
      ),
    );
  }
}