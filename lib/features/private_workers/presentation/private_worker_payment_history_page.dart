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
      ),import 'package:flutter/material.dart';

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
        future: dao.getByWorker(workerId),
        builder: (_, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No payment history',
              ),
            );
          }

          final data = snapshot.data!;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, index) {
              final payment = data[index];

              final isDadToWorker =
                  payment.direction ==
                      'dad_to_worker';

              return Card(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: Icon(
                    isDadToWorker
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: isDadToWorker
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(
                    '₹${payment.amount.toStringAsFixed(0)}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        '${payment.date} • ${payment.mode}',
                      ),
                      Text(
                        isDadToWorker
                            ? 'Dad → Worker'
                            : 'Worker → Dad',
                      ),
                      if (payment.notes !=
                              null &&
                          payment.notes!
                              .isNotEmpty)
                        Text(payment.notes!),
                    ],
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
    );
  }
}