import 'package:flutter/material.dart';
import '../data/private_work_dao.dart';
import '../data/private_work_model.dart';
import 'add_edit_private_work_page.dart';

class PrivateWorkListPage extends StatefulWidget {
  const PrivateWorkListPage({super.key});

  @override
  State<PrivateWorkListPage> createState() => _PrivateWorkListPageState();
}

class _PrivateWorkListPageState extends State<PrivateWorkListPage> {
  final _dao = PrivateWorkDao();
  List<PrivateWork> works = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    works = await _dao.getAll();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Private Works')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final ok = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditPrivateWorkPage()),
          );
          if (ok == true) load();
        },
      ),
      body: works.isEmpty
          ? const Center(child: Text('No private works'))
          : ListView.builder(
        itemCount: works.length,
        itemBuilder: (_, i) {
          final w = works[i];
          return Card(
            child: ListTile(
              title: Text(w.workerName),
              subtitle: Text('${w.workType} • ${w.siteName}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color:
                    w.status == 'Active' ? Colors.green : Colors.grey,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final ok = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddEditPrivateWorkPage(work: w),
                        ),
                      );
                      if (ok == true) load();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}