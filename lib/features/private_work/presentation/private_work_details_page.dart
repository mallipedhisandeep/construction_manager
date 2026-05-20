import 'package:flutter/material.dart';

import '../data/private_work_dao.dart';
import '../data/private_work_model.dart';

class PrivateWorkDetailsPage
    extends StatelessWidget {
  final PrivateWork work;

  PrivateWorkDetailsPage({
    super.key,
    required this.work,
  });

  final PrivateWorkDao _dao =
      PrivateWorkDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          work.workerName,
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Work Type: ${work.workType}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Site: ${work.siteName}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Date: ${work.workDate}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Price Charged: ₹${work.priceCharged.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Amount Paid: ₹${work.amountPaid.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Balance: ₹${(work.priceCharged - work.amountPaid).toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
                color:
                    (work.priceCharged -
                                work.amountPaid) >
                            0
                        ? Colors.red
                        : Colors.green,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Status: ${work.status}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            if (work.notes != null &&
                work.notes!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(
                height: 16,
              ),

              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                work.notes!,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ],

            const SizedBox(
              height: 30,
            ),

            ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),
              onPressed: () async {
                final confirm =
                    await showDialog<bool>(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title:
                            const Text(
                          'Delete Work',
                        ),
                        content:
                            const Text(
                          'Are you sure you want to delete this work entry?',
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

                try {
                  await _dao.delete(
                    work.id!,
                  );

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.pop(
                    context,
                    true,
                  );
                } catch (e) {
                  debugPrint(
                    'DELETE PRIVATE WORK ERROR => $e',
                  );
                }
              },
              icon: const Icon(
                Icons.delete,
              ),
              label: const Text(
                'Delete Work',
              ),
            ),
          ],
        ),
      ),
    );
  }
}