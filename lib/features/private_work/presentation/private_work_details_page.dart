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

  final _dao = PrivateWorkDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(work.workerName),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Work Type: ${work.workType}',
            ),

            const SizedBox(height: 8),

            Text(
              'Site: ${work.siteName}',
            ),

            const SizedBox(height: 8),

            Text(
              'Date: ${work.workDate}',
            ),

            const SizedBox(height: 8),

            Text(
              'Price Charged: ₹${work.priceCharged.toStringAsFixed(0)}',
            ),

            const SizedBox(height: 8),

            Text(
              'Amount Paid: ₹${work.amountPaid.toStringAsFixed(0)}',
            ),

            const SizedBox(height: 8),

            Text(
              'Status: ${work.status}',
            ),

            if (work.notes != null &&
                work.notes!
                    .isNotEmpty) ...[
              const SizedBox(
                height: 12,
              ),
              Text(
                'Notes: ${work.notes}',
              ),
            ],

            const SizedBox(height: 24),

            ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),
              onPressed: () async {
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