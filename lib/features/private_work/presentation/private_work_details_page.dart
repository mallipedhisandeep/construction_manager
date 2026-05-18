import 'package:flutter/material.dart';
import '../data/private_work_model.dart';
import '../data/private_work_dao.dart';

class PrivateWorkDetailsPage extends StatelessWidget {
  final PrivateWork work;
  final _dao = PrivateWorkDao();

  PrivateWorkDetailsPage({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(work.workerName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Work: ${work.workType}'),
            Text('Site: ${work.siteName}'),
            Text('Date: ${work.workDate}'),
            Text('Price: ₹${work.priceCharged}'),
            Text('Paid: ₹${work.amountPaid}'),
            Text('Status: ${work.status}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _dao.delete(work.id!);
                Navigator.pop(context, true);
              },
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}