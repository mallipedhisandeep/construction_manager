import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String? id;

  final String workerId;

  final String? siteId;

  final DateTime date;

  final String attendanceType;

  final double wage;

  final double advance;

  final String paymentMode;

  final String? paymentRef;

  final double balanceAfter;

  final Timestamp createdAt;

  AttendanceModel({
    this.id,
    required this.workerId,
    this.siteId,
    required this.date,
    required this.attendanceType,
    required this.wage,
    required this.advance,
    required this.paymentMode,
    this.paymentRef,
    required this.balanceAfter,
    Timestamp? createdAt,
  }) : createdAt =
           createdAt ??
           Timestamp.now();

  // =========================
  // DATE KEY
  // =========================

  String get dateKey =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  // =========================
  // TO MAP
  // =========================

  Map<String, dynamic> toMap() {
    return {
      'worker_id': workerId,

      'site_id': siteId,

      'date': Timestamp.fromDate(
        DateTime(
          date.year,
          date.month,
          date.day,
        ),
      ),

      'date_key': dateKey,

      'attendance_type':
          attendanceType,

      'wage': wage,

      'advance': advance,

      'payment_mode':
          paymentMode,

      'payment_ref': paymentRef,

      'balance_after':
          balanceAfter,

      'created_at':
          createdAt,
    };
  }

  // =========================
  // FROM MAP
  // =========================

  factory AttendanceModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    final Timestamp timestamp =
        map['date'];

    return AttendanceModel(
      id: documentId,

      workerId:
          map['worker_id'] ?? '',

      siteId:
          map['site_id'],

      date:
          timestamp.toDate(),

      attendanceType:
          map['attendance_type'] ??
              '',

      wage:
          (map['wage'] ?? 0)
              .toDouble(),

      advance:
          (map['advance'] ?? 0)
              .toDouble(),

      paymentMode:
          map['payment_mode'] ??
              '',

      paymentRef:
          map['payment_ref'],

      balanceAfter:
          (map['balance_after'] ??
                  0)
              .toDouble(),

      createdAt:
          map['created_at'] ??
              Timestamp.now(),
    );
  }

  // =========================
  // COPY WITH
  // =========================

  AttendanceModel copyWith({
    double? balanceAfter,
  }) {
    return AttendanceModel(
      id: id,

      workerId: workerId,

      siteId: siteId,

      date: date,

      attendanceType:
          attendanceType,

      wage: wage,

      advance: advance,

      paymentMode:
          paymentMode,

      paymentRef:
          paymentRef,

      balanceAfter:
          balanceAfter ??
              this.balanceAfter,

      createdAt: createdAt,
    );
  }
}