import 'package:flutter/material.dart';

import '../data/private_worker_payment_dao.dart';
import '../data/private_worker_payment_model.dart';

class PrivateWorkerPaymentHistoryPage
    extends StatefulWidget {
  final String workerId;

  const PrivateWorkerPaymentHistoryPage({
    super.key,
    required this.workerId,
  });

  @override
  State<PrivateWorkerPaymentHistoryPage>
      createState() =>
          _PrivateWorkerPaymentHistoryPageState();
}

class _PrivateWorkerPaymentHistoryPageState
    extends State<
        PrivateWorkerPaymentHistoryPage> {
  final PrivateWorkerPaymentDao
      _dao =
      PrivateWorkerPaymentDao();

  bool loading = true;

  List<PrivateWorkerPayment>
      payments = [];

  @override
  void initState() {
    super.initState();

    load();
  }

  Future<void> load() async {
    try {
      payments =
          await _dao.getByWorker(
        widget.workerId,
      );
    } catch (e) {
      debugPrint(
        'LOAD PAYMENT HISTORY ERROR => $e',
      );
    }

    loading = false;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment History',
        ),
      ),
      body:
          loading
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : payments.isEmpty
              ? const Center(
                  child: Text(
                    'No payment history',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: load,
                  child: ListView.builder(
                    itemCount:
                        payments.length,
                    itemBuilder:
                        (_, index) {
                      final payment =
                          payments[index];

                      final bool dadToWorker =
                          payment.direction ==
                              'dad_to_worker';

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
                                dadToWorker
                                    ? Colors.green
                                    : Colors.red,
                            child: Icon(
                              dadToWorker
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color:
                                  Colors.white,
                            ),
                          ),

                          title: Text(
                            '₹${payment.amount.toStringAsFixed(0)}',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                '${payment.date} • ${payment.mode}',
                              ),

                              if (payment.notes !=
                                      null &&
                                  payment.notes!
                                      .trim()
                                      .isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    top: 4,
                                  ),
                                  child: Text(
                                    payment.notes!,
                                  ),
                                ),
                            ],
                          ),

                          trailing: Text(
                            dadToWorker
                                ? 'Dad → Worker'
                                : 'Worker → Dad',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  dadToWorker
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}