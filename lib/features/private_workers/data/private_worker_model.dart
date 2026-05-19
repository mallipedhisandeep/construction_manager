import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateWorker {
  final String? id;
  final String name;
  final String workType;
  final String phone;
  final String? notes;
  final DateTime createdAt;

  PrivateWorker({
    this.id,
    required this.name,
    required this.workType,
    required this.phone,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'work_type': workType,
      'phone': phone,
      'notes': notes,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory PrivateWorker.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return PrivateWorker(
      id: documentId,
      name: map['name'] ?? '',
      workType: map['work_type'] ?? '',
      phone: map['phone'] ?? '',
      notes: map['notes'],
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
  }
}