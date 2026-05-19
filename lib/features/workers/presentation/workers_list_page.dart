import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/worker_dao.dart';
import '../data/worker_model.dart';

import 'add_worker_page.dart';
import 'worker_details_page.dart';

class WorkersListPage extends StatefulWidget {
  const WorkersListPage({super.key});

  @override
  State<WorkersListPage> createState() =>
      _WorkersListPageState();
}

class _WorkersListPageState
    extends State<WorkersListPage> {

  final WorkerDao _dao = WorkerDao();

  List<WorkerModel> workers = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWorkers();
  }

  // ==============================
  // LOAD WORKERS FROM FIRESTORE
  // ==============================

  Future<void> loadWorkers() async {
    try {
      final data = await _dao.getAllWorkers();

      setState(() {
        workers = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint(
        'Error loading workers: $e',
      );
    }
  }

  // ==============================
  // DELETE WORKER
  // ==============================

  Future<void> deleteWorker(
    String workerId,
  ) async {
    try {
      await _dao.deleteWorker(workerId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Worker deleted'),
        ),
      );

      loadWorkers();
    } catch (e) {
      debugPrint(
        'Delete error: $e',
      );
    }
  }

  // ==============================
  // CALL WORKER
  // ==============================

  Future<void> callWorker(
    String phone,
  ) async {
    final uri = Uri.parse('tel:$phone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workers'),
      ),

      // ==========================
      // ADD WORKER BUTTON
      // ==========================

      floatingActionButton:
          FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () async {
          final result =
              await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddWorkerPage(),
            ),
          );

          if (result == true) {
            loadWorkers();
          }
        },
      ),

      // ==========================
      // BODY
      // ==========================

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : workers.isEmpty
              ? const Center(
                  child: Text(
                    'No workers added',
                  ),
                )

              : RefreshIndicator(
                  onRefresh: loadWorkers,

                  child: ListView.builder(
                    itemCount: workers.length,

                    itemBuilder:
                        (context, index) {

                      final worker =
                          workers[index];

                      return Card(
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Colors.deepPurple,
                            child: Text(
                              worker.name
                                  .isNotEmpty
                                  ? worker.name[0]
                                      .toUpperCase()
                                  : '?',
                              style:
                                  const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // ==================
                          // WORKER NAME
                          // ==================

                          title: Text(
                            worker.name,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          // ==================
                          // WORKER DETAILS
                          // ==================

                          subtitle: Text(
                            '${worker.workType} • '
                            '${worker.state} • '
                            '${worker.role}',
                          ),

                          // ==================
                          // ACTION BUTTONS
                          // ==================

                          trailing: Row(
                            mainAxisSize:
                                MainAxisSize.min,

                            children: [

                              // CALL BUTTON
                              if (worker.phone
                                  .isNotEmpty)
                                IconButton(
                                  icon: const Icon(
                                    Icons.call,
                                    color:
                                        Colors.green,
                                  ),

                                  onPressed: () {
                                    callWorker(
                                      worker.phone,
                                    );
                                  },
                                ),

                              // DELETE BUTTON
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),

                                onPressed: () async {

                                  final confirm =
                                      await showDialog<bool>(
                                    context:
                                        context,

                                    builder:
                                        (context) {
                                      return AlertDialog(
                                        title:
                                            const Text(
                                          'Delete Worker',
                                        ),

                                        content:
                                            const Text(
                                          'Are you sure?',
                                        ),

                                        actions: [

                                          TextButton(
                                            onPressed:
                                                () {
                                              Navigator.pop(
                                                context,
                                                false,
                                              );
                                            },

                                            child:
                                                const Text(
                                              'Cancel',
                                            ),
                                          ),

                                          TextButton(
                                            onPressed:
                                                () {
                                              Navigator.pop(
                                                context,
                                                true,
                                              );
                                            },

                                            child:
                                                const Text(
                                              'Delete',
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm ==
                                      true) {

                                    if (worker.id !=
                                        null) {

                                      deleteWorker(
                                        worker.id!,
                                      );
                                    }
                                  }
                                },
                              ),

                              const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size: 16,
                              ),
                            ],
                          ),

                          // ==================
                          // OPEN DETAILS PAGE
                          // ==================

                          onTap: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    WorkerDetailsPage(
                                  worker: worker,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
} 