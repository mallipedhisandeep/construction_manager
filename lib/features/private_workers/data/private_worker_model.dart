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
      'workType': workType,
      'phone': phone,
      'notes': notes,
      'createdAt':
          Timestamp.fromDate(
        createdAt,
      ),
    };
  }

  factory PrivateWorker.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return PrivateWorker(
      id: docId,
      name: map['name'] ?? '',
      workType:
          map['workType'] ?? '',
      phone: map['phone'] ?? '',
      notes: map['notes'],
      createdAt:
          (map['createdAt']
                  as Timestamp)
              .toDate(),
    );
  }
}