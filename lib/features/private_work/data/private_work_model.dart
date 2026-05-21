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

      'worker_id': workerId,

      'worker_name': workerName,

      'work_type': workType,

      'site_id': siteId,

      'site_name': siteName,

      'work_date': workDate,

      'price_charged': priceCharged,

      'amount_paid': amountPaid,

      'status': status,

      'notes': notes,

      'created_at':
          createdAt.toIso8601String(),
    };
  }

  factory PrivateWork.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {

    return PrivateWork(

      id: docId,

      workerId:
          map['worker_id'] ?? '',

      workerName:
          map['worker_name'] ?? '',

      workType:
          map['work_type'] ?? '',

      siteId:
          map['site_id'] ?? '',

      siteName:
          map['site_name'] ?? '',

      workDate:
          map['work_date'] ?? '',

      priceCharged:
          (map['price_charged'] ?? 0)
              .toDouble(),

      amountPaid:
          (map['amount_paid'] ?? 0)
              .toDouble(),

      status:
          map['status'] ?? '',

      notes:
          map['notes'],

      createdAt:
          map['created_at'] != null
              ? DateTime.parse(
                  map['created_at'],
                )
              : DateTime.now(),
    );
  }
}