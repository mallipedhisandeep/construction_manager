import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/private_worker_dao.dart';
import '../data/private_worker_model.dart';

import '../data/private_worker_payment_dao.dart';
import '../data/private_worker_payment_model.dart';

import 'add_edit_private_worker_page.dart';
import 'private_worker_payment_history_page.dart';

class PrivateWorkerDetailsPage
    extends StatefulWidget {
  final PrivateWorker worker;

  const PrivateWorkerDetailsPage({
    super.key,
    required this.worker,
  });

  @override
  State<PrivateWorkerDetailsPage>
      createState() =>
          _PrivateWorkerDetailsPageState();
}

class _PrivateWorkerDetailsPageState
    extends State<
        PrivateWorkerDetailsPage> {
  final PrivateWorkerDao _dao =
      PrivateWorkerDao();

  final PrivateWorkerPaymentDao
      _paymentDao =
      PrivateWorkerPaymentDao();

  PrivateWorkerSummary? summary;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    load();
  }

  Future<void> load() async {
    try {
      summary =
          await _dao.getSummary(
        widget.worker.id!,
      );
    } catch (e) {
      debugPrint(
        'LOAD SUMMARY ERROR => $e',
      );
    }

    loading = false;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.worker.name,
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.delete),
            onPressed: deleteWorker,
          ),
        ],
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Work Type: ${widget.worker.workType}',
            ),

            const SizedBox(
              height: 8,
            ),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Phone: ${widget.worker.phone}',
                  ),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.call,
                    color: Colors.green,
                  ),
                  onPressed: () async {
                    final Uri uri =
                        Uri.parse(
                      'tel:${widget.worker.phone}',
                    );

                    await launchUrl(
                      uri,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Last Site: ${summary?.lastSite ?? '-'}',
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'Last Date: ${summary?.lastDate ?? '-'}',
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              summary!.balance == 0
                  ? 'Balance Settled'
                  : summary!.balance > 0
                      ? 'Dad should give ₹${summary!.balance.toStringAsFixed(0)}'
                      : 'Worker should give ₹${summary!.balance.abs().toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
                color:
                    summary!.balance ==
                            0
                        ? Colors.grey
                        : summary!
                                    .balance >
                                0
                            ? Colors.green
                            : Colors.red,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            ElevatedButton.icon(
              icon:
                  const Icon(Icons.edit),
              label: const Text(
                'Edit Worker',
              ),
              onPressed: () async {
                final ok =
                    await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddEditPrivateWorkerPage(
                      worker:
                          widget.worker,
                    ),
                  ),
                );

                if (ok == true) {
                  await load();
                }
              },
            ),

            const SizedBox(
              height: 12,
            ),

            ElevatedButton.icon(
              icon: const Icon(
                Icons.payments,
              ),
              label: const Text(
                'Add Payment',
              ),
              onPressed: addPayment,
            ),

            const SizedBox(
              height: 12,
            ),

            ElevatedButton.icon(
              icon:
                  const Icon(Icons.history),
              label: const Text(
                'Payment History',
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PrivateWorkerPaymentHistoryPage(
                      workerId:
                          widget.worker.id!,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // ADD PAYMENT
  // =========================

  Future<void> addPayment() async {
    double amount = 0;

    String direction =
        'dad_to_worker';

    String mode = 'Cash';

    final TextEditingController
        noteCtrl =
        TextEditingController();

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text(
              'Add Payment',
            ),
            content:
                SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  TextField(
                    keyboardType:
                        TextInputType
                            .number,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Amount',
                    ),
                    onChanged: (v) {
                      amount =
                          double.tryParse(
                                v,
                              ) ??
                              0;
                    },
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  DropdownButtonFormField<
                      String>(
                    initialValue:
                        direction,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Direction',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value:
                            'dad_to_worker',
                        child: Text(
                          'Dad → Worker',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'worker_to_dad',
                        child: Text(
                          'Worker → Dad',
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        direction = v;
                      }
                    },
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  DropdownButtonFormField<
                      String>(
                    initialValue: mode,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Mode',
                    ),
                    items:
                        const [
                          'Cash',
                          'Online',
                        ]
                            .map(
                              (e) =>
                                  DropdownMenuItem(
                                value: e,
                                child:
                                    Text(e),
                              ),
                            )
                            .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        mode = v;
                      }
                    },
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  TextField(
                    controller:
                        noteCtrl,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Notes',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child:
                    const Text(
                  'Cancel',
                ),
              ),

              ElevatedButton(
                onPressed: () async {
                  if (amount <= 0) {
                    return;
                  }

                  await _paymentDao.insert(
                    PrivateWorkerPayment(
                      workerId:
                          widget.worker.id!,
                      amount: amount,
                      direction:
                          direction,
                      mode: mode,
                      date: DateTime.now()
                          .toIso8601String()
                          .split('T')
                          .first,
                      source: 'manual',
                      notes:
                          noteCtrl.text
                              .trim(),
                      createdAt:
                          Timestamp.now(),
                    ),
                  );

                  if (!mounted) {
                    return;
                  }

                  Navigator.pop(
                    context,
                  );

                  await load();
                },
                child:
                    const Text(
                  'Save',
                ),
              ),
            ],
          ),
    );
  }

  // =========================
  // DELETE
  // =========================

  Future<void> deleteWorker() async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title:
                const Text(
              'Delete',
            ),
            content:
                const Text(
              'Delete this worker?',
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

    if (confirm != true) {
      return;
    }

    await _dao.delete(
      widget.worker.id!,
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(
      context,
      true,
    );
  }
}