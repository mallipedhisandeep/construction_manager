import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/private_worker_dao.dart';
import '../data/private_worker_model.dart';

import 'add_edit_private_worker_page.dart';
import 'private_worker_details_page.dart';

class PrivateWorkersListPage
    extends StatefulWidget {
  const PrivateWorkersListPage({
    super.key,
  });

  @override
  State<PrivateWorkersListPage>
      createState() =>
          _PrivateWorkersListPageState();
}

class _PrivateWorkersListPageState
    extends State<
        PrivateWorkersListPage> {
  final _dao = PrivateWorkerDao();

  List<PrivateWorker> workers = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    workers = await _dao.getAll();

    loading = false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Private Workers'),
      ),
      floatingActionButton:
          FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final ok =
              await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddEditPrivateWorkerPage(),
            ),
          );

          if (ok == true) {
            load();
          }
        },
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : workers.isEmpty
              ? const Center(
                  child: Text(
                    'No private workers added',
                  ),
                )
              : ListView.builder(
                  itemCount:
                      workers.length,
                  itemBuilder:
                      (_, index) {
                    final worker =
                        workers[index];

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(
                          worker.name,
                        ),
                        subtitle: Text(
                          worker.workType,
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.call,
                            color:
                                Colors.green,
                          ),
                          onPressed: () {
                            launchUrl(
                              Uri.parse(
                                'tel:${worker.phone}',
                              ),
                            );
                          },
                        ),
                        onTap: () async {
                          final changed =
                              await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PrivateWorkerDetailsPage(
                                worker:
                                    worker,
                              ),
                            ),
                          );

                          if (changed ==
                              true) {
                            load();
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}