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

      'workerId': workerId,

      'amount': amount,

      'direction': direction,

      'mode': mode,

      'date': date,

      'notes': notes,

      'source': source,

      'createdAt':
          createdAt.toIso8601String(),
    };
  }

  factory PrivateWorkerPayment.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {

    return PrivateWorkerPayment(

      id: docId,

      workerId:
          map['workerId'] ?? '',

      amount:
          (map['amount'] ?? 0)
              .toDouble(),

      direction:
          map['direction'] ?? '',

      mode:
          map['mode'] ?? '',

      date:
          map['date'] ?? '',

      notes:
          map['notes'],

      source:
          map['source'] ?? '',

      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(
                  map['createdAt'],
                )
              : DateTime.now(),
    );
  }

  PrivateWorkerPayment copyWith({

    String? id,

    String? workerId,

    double? amount,

    String? direction,

    String? mode,

    String? date,

    String? notes,

    String? source,

    DateTime? createdAt,

  }) {

    return PrivateWorkerPayment(

      id:
          id ?? this.id,

      workerId:
          workerId ?? this.workerId,

      amount:
          amount ?? this.amount,

      direction:
          direction ?? this.direction,

      mode:
          mode ?? this.mode,

      date:
          date ?? this.date,

      notes:
          notes ?? this.notes,

      source:
          source ?? this.source,

      createdAt:
          createdAt ?? this.createdAt,
    );
  }
}