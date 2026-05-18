class PrivateWork {
  final int? id;
  final int workerId;
  final String workerName;
  final String workType;
  final String siteName;
  final String workDate;
  final double priceCharged;
  final double amountPaid;
  final String status;
  final String? notes;

  PrivateWork({
    this.id,
    required this.workerId,
    required this.workerName,
    required this.workType,
    required this.siteName,
    required this.workDate,
    required this.priceCharged,
    required this.amountPaid,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'worker_id': workerId,
      'worker_name': workerName,
      'work_type': workType,
      'site_name': siteName,
      'work_date': workDate,
      'price_charged': priceCharged,
      'amount_paid': amountPaid,
      'status': status,
      'notes': notes,
    };
  }

  factory PrivateWork.fromMap(Map<String, dynamic> map) {
    return PrivateWork(
      id: map['id'],
      workerId: map['worker_id'],
      workerName: map['worker_name'],
      workType: map['work_type'],
      siteName: map['site_name'],
      workDate: map['work_date'],
      priceCharged: (map['price_charged'] as num).toDouble(),
      amountPaid: (map['amount_paid'] as num).toDouble(),
      status: map['status'],
      notes: map['notes'],
    );
  }
}