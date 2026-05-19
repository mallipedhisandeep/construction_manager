import 'package:flutter/material.dart';

import '../data/private_worker_payment_dao.dart';
import '../data/private_worker_payment_model.dart';

class PrivateWorkerPaymentHistoryPage
    extends StatelessWidget {
  final String workerId;

  const PrivateWorkerPaymentHistoryPage({
    super.key,
    required this.workerId,
  });

  @override
  Widget build(BuildContext context) {
    final dao = PrivateWorkerPaymentDao();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment History',
        ),
      ),
      body: FutureBuilder<
          List<PrivateWorkerPayment>>(
        future: dao.getByWorker(
          workerId,
        ),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!;

          if (data.isEmpty) {
            return const Center(
              child: Text(
                'No payment history',
              ),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, index) {
              final payment =
                  data[index];

              return Card(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  title: Text(
                    '₹${payment.amount.toStringAsFixed(0)}',
                  ),
                  subtitle: Text(
                    '${payment.date} • ${payment.mode}',
                  ),
                  trailing: Text(
                    payment.direction ==
                            'dad_to_worker'
                        ? 'Dad → Worker'
                        : 'Worker → Dad',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}