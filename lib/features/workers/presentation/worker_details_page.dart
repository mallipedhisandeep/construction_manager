import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/worker_dao.dart';
import '../data/worker_model.dart';

import 'add_worker_page.dart';

class WorkerDetailsPage
    extends StatelessWidget {

  final WorkerModel worker;

  const WorkerDetailsPage({
    super.key,
    required this.worker,
  });

  Future<void> _callWorker(
    String phone,
  ) async {

    final uri =
        Uri.parse(
      'tel:$phone',
    );

    await launchUrl(uri);
  }

  Widget _detailRow(
    String label,
    String value,
  ) {

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),

      child: Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          SizedBox(

            width: 140,

            child: Text(

              label,

              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _wageRow(
    String shift,
    double amount,
  ) {

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),

      child: Row(

        children: [

          Expanded(
            child: Text(shift),
          ),

          Text(
            '₹${amount.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text(
          'Worker Details',
        ),
      ),

      body: Center(

        child: ConstrainedBox(

          constraints:
              const BoxConstraints(
            maxWidth: 800,
          ),

          child: ListView(

            padding:
                const EdgeInsets.all(
              16,
            ),

            children: [

              Card(

                child: Padding(

                  padding:
                      const EdgeInsets.all(
                    20,
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Row(

                        children: [

                          CircleAvatar(

                            radius: 32,

                            backgroundColor:
                                Colors.deepPurple,

                            child: Text(

                              worker.name
                                      .isNotEmpty
                                  ? worker
                                      .name[0]
                                      .toUpperCase()
                                  : '?',

                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 16,
                          ),

                          Expanded(

                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(

                                  worker.name,

                                  style:
                                      const TextStyle(
                                    fontSize: 24,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  '${worker.workType} • ${worker.role}',
                                ),
                              ],
                            ),
                          ),

                          if (worker.phone
                              .isNotEmpty)

                            IconButton(

                              icon:
                                  const Icon(
                                Icons.call,
                                color:
                                    Colors.green,
                                size: 28,
                              ),

                              onPressed: () {
                                _callWorker(
                                  worker.phone,
                                );
                              },
                            ),
                        ],
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      const Text(

                        'Basic Details',

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const Divider(),

                      _detailRow(
                        'Phone',
                        worker.phone,
                      ),

                      _detailRow(
                        'Gender',
                        worker.gender,
                      ),

                      _detailRow(
                        'State',
                        worker.state,
                      ),

                      _detailRow(
                        'Role',
                        worker.role,
                      ),

                      _detailRow(
                        'Work Type',
                        worker.workType,
                      ),

                      if (worker.notes != null &&
                          worker.notes!
                              .trim()
                              .isNotEmpty) ...[

                        const SizedBox(
                          height: 20,
                        ),

                        const Text(

                          'Notes',

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const Divider(),

                        Text(
                          worker.notes!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Card(

                child: Padding(

                  padding:
                      const EdgeInsets.all(
                    20,
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(

                        'Wages',

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const Divider(),

                      _wageRow(
                        '6 AM – 6 PM',
                        worker.rate6to6,
                      ),

                      _wageRow(
                        '10 AM – 6 PM',
                        worker.rate10to6,
                      ),

                      _wageRow(
                        '6 AM – 10 PM',
                        worker.rate6to10,
                      ),

                      _wageRow(
                        '6 AM – 2 PM',
                        worker.rate6to2,
                      ),

                      _wageRow(
                        '10 AM – 2 PM',
                        worker.rate10to2,
                      ),

                      _wageRow(
                        '2 PM – 6 PM',
                        worker.rate2to6,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              Wrap(

                spacing: 12,
                runSpacing: 12,

                children: [

                  SizedBox(

                    height: 50,
                    width: 220,

                    child: ElevatedButton.icon(

                      icon:
                          const Icon(
                        Icons.edit,
                      ),

                      label:
                          const Text(
                        'Edit Worker',
                      ),

                      onPressed:
                          () async {

                        final changed =
                            await Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                AddWorkerPage(
                              worker:
                                  worker,
                            ),
                          ),
                        );

                        if (changed ==
                                true &&
                            context.mounted) {

                          Navigator.pop(
                            context,
                            true,
                          );
                        }
                      },
                    ),
                  ),

                  SizedBox(

                    height: 50,
                    width: 220,

                    child: ElevatedButton.icon(

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.red,
                      ),

                      icon:
                          const Icon(
                        Icons.delete,
                      ),

                      label:
                          const Text(
                        'Delete Worker',
                      ),

                      onPressed:
                          () async {

                        final confirm =
                            await showDialog<bool>(
                          context: context,

                          builder: (_) =>
                              AlertDialog(

                            title:
                                const Text(
                              'Delete Worker',
                            ),

                            content:
                                const Text(
                              'Are you sure you want to delete this worker?',
                            ),

                            actions: [

                              TextButton(

                                onPressed: () {

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

                              ElevatedButton(

                                onPressed: () {

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
                          ),
                        );

                        if (confirm ==
                            true) {

                          if (worker.id !=
                              null) {

                            await WorkerDao()
                                .deleteWorker(
                              worker.id!,
                            );

                            if (context
                                .mounted) {

                              Navigator.pop(
                                context,
                                true,
                              );
                            }
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}