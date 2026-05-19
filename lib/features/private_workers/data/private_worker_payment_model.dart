import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateWorkerPayment {
  final String? id;
  final String workerId;
  final double amount;
  final String direction;
  final String mode;
  final String date;
  final String? notes;
  final String source;
  final DateTime createdAt;

  PrivateWorkerPayment({
    this.id,
    required this.workerId,
    required this.amount,
    required this.direction,
    required this.mode,
    required this.date,
    this.notes,
    required this.source,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'worker_id': workerId,
      'amount': amount,
      'direction': direction,
      'mode': mode,
      'date': date,
      'notes': notes,
      'source': source,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory PrivateWorkerPayment.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return PrivateWorkerPayment(
      id: documentId,
      workerId: map['worker_id'],
      amount: (map['amount'] ?? 0).toDouble(),
      direction: map['direction'],
      mode: map['mode'],
      date: map['date'],
      notes: map['notes'],
      source: map['source'],
      createdAt:
          (map['created_at'] as Timestamp).toDate(),
    );
  }
}