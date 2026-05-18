class AttendanceModel {
  final int? id;
  final int workerId;
  final int? siteId;
  final DateTime date;
  final String attendanceType;
  final double wage;
  final double advance;
  final String paymentMode;
  final String? paymentRef;
  final double balanceAfter;

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
  });

  /// 🔑 yyyy-MM-dd (NO TIME)
  String get dateKey =>
      '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'worker_id': workerId,
      'site_id': siteId,
      'date': dateKey,
      'attendance_type': attendanceType,
      'wage': wage,
      'advance': advance,
      'payment_mode': paymentMode,
      'payment_ref': paymentRef,
      'balance_after': balanceAfter,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'],
      workerId: map['worker_id'],
      siteId: map['site_id'],
      date: DateTime.parse(map['date']),
      attendanceType: map['attendance_type'],
      wage: (map['wage'] as num).toDouble(),
      advance: (map['advance'] as num).toDouble(),
      paymentMode: map['payment_mode'],
      paymentRef: map['payment_ref'],
      balanceAfter: (map['balance_after'] as num).toDouble(),
    );
  }

  AttendanceModel copyWith({double? balanceAfter}) {
    return AttendanceModel(
      id: id,
      workerId: workerId,
      siteId: siteId,
      date: date,
      attendanceType: attendanceType,
      wage: wage,
      advance: advance,
      paymentMode: paymentMode,
      paymentRef: paymentRef,
      balanceAfter: balanceAfter ?? this.balanceAfter,
    );
  }
}