import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateWork {
  final String? id;

  final String workerId;
  final String workerName;

  final String workType;

  final String siteId;
  final String siteName;

  final String workDate;

  final double priceCharged;
  final double amountPaid;

  final String status;

  final String? notes;

  final DateTime createdAt;

  PrivateWork({
    this.id,
    required this.workerId,
    required this.workerName,
    required this.workType,
    required this.siteId,
    required this.siteName,
    required this.workDate,
    required this.priceCharged,
    required this.amountPaid,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'workerId': workerId,
      'workerName': workerName,
      'workType': workType,
      'siteId': siteId,
      'siteName': siteName,
      'workDate': workDate,
      'priceCharged': priceCharged,
      'amountPaid': amountPaid,
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PrivateWork.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return PrivateWork(
      id: docId,
      workerId: map['workerId'] ?? '',
      workerName: map['workerName'] ?? '',
      workType: map['workType'] ?? '',
      siteId: map['siteId'] ?? '',
      siteName: map['siteName'] ?? '',
      workDate: map['workDate'] ?? '',
      priceCharged:
          (map['priceCharged'] ?? 0).toDouble(),
      amountPaid:
          (map['amountPaid'] ?? 0).toDouble(),
      status: map['status'] ?? 'Active',
      notes: map['notes'],
      createdAt:
          (map['createdAt'] as Timestamp)
              .toDate(),
    );
  }
}