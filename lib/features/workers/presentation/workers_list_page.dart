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

  Future<void> deleteWorker(
    String workerId,
  ) async {
    try {
      await _dao.deleteWorker(
        workerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text('Worker deleted'),
        ),
      );
    } catch (e) {
      debugPrint(
        'Delete error: $e',
      );
    }
  }

  Future<void> callWorker(
    String phone,
  ) async {
    final uri =
        Uri.parse('tel:$phone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Workers'),
      ),

      floatingActionButton:
          FloatingActionButton(
        child:
            const Icon(Icons.add),

        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddWorkerPage(),
            ),
          );
        },
      ),

      body:
          StreamBuilder<
              List<WorkerModel>>(
        stream:
            _dao.watchWorkers(),

        builder: (
          context,
          snapshot,
        ) {
          if (snapshot
                  .connectionState ==
              ConnectionState
                  .waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          final workers =
              snapshot.data ?? [];

          if (workers.isEmpty) {
            return const Center(
              child: Text(
                'No workers added',
              ),
            );
          }

          return ListView.builder(
            itemCount:
                workers.length,

            itemBuilder:
                (
                  context,
                  index,
                ) {
              final worker =
                  workers[index];

              return Card(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                child: ListTile(
                  leading:
                      CircleAvatar(
                    backgroundColor:
                        Colors
                            .deepPurple,

                    child: Text(
                      worker.name
                              .isNotEmpty
                          ? worker
                              .name[0]
                              .toUpperCase()
                          : '?',

                      style:
                          const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  title: Text(
                    worker.name,

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),

                  subtitle: Text(
                    '${worker.workType} • '
                    '${worker.state} • '
                    '${worker.role}',
                  ),

                  trailing: Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      if (worker.phone
                          .isNotEmpty)
                        IconButton(
                          icon:
                              const Icon(
                            Icons.call,
                            color: Colors
                                .green,
                          ),

                          onPressed:
                              () {
                            callWorker(
                              worker
                                  .phone,
                            );
                          },
                        ),

                      IconButton(
                        icon:
                            const Icon(
                          Icons.delete,
                          color:
                              Colors.red,
                        ),

                        onPressed:
                            () async {
                          final confirm =
                              await showDialog<bool>(
                            context:
                                context,

                            builder:
                                (
                                  context,
                                ) {
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
                                  true &&
                              worker.id !=
                                  null) {
                            deleteWorker(
                              worker.id!,
                            );
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

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            WorkerDetailsPage(
                          worker:
                              worker,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}