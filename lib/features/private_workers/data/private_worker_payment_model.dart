class PrivateWorkerPayment {
  final int? id;
  final int workerId;
  final double amount;
  final String direction;
  final String mode;
  final String date;
  final String? notes;
  final String source;

  PrivateWorkerPayment({
    this.id,
    required this.workerId,
    required this.amount,
    required this.direction,
    required this.mode,
    required this.date,
    this.notes,
    required this.source,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'worker_id': workerId,
    'amount': amount,
    'direction': direction,
    'mode': mode,
    'date': date,
    'notes': notes,
    'source': source,
  };

  factory PrivateWorkerPayment.fromMap(Map<String, dynamic> m) =>
      PrivateWorkerPayment(
        id: m['id'],
        workerId: m['worker_id'],
        amount: (m['amount'] as num).toDouble(),
        direction: m['direction'],
        mode: m['mode'],
        date: m['date'],
        notes: m['notes'],
        source: m['source'],
      );
}