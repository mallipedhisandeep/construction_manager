import 'package:flutter/material.dart';
import '../data/private_worker_payment_dao.dart';

class PrivateWorkerPaymentHistoryPage extends StatelessWidget {
  final int workerId;
  const PrivateWorkerPaymentHistoryPage({super.key, required this.workerId});

  @override
  Widget build(BuildContext context) {
    final dao = PrivateWorkerPaymentDao();

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: FutureBuilder(
        future: dao.getByWorker(workerId),
        builder: (_, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final data = s.data!;
          return ListView(
            children: data
                .map((e) => ListTile(
              title: Text('₹${e.amount}'),
              subtitle: Text('${e.date} • ${e.mode}'),
            ))
                .toList(),
          );
        },
      ),
    );
  }
}