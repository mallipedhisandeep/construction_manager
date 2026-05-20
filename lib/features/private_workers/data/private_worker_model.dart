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

  // =========================
  // TO MAP
  // =========================

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'work_type': workType,
      'phone': phone,
      'notes': notes,
      'created_at':
          createdAt.toIso8601String(),
    };
  }

  // =========================
  // FROM MAP
  // =========================

  factory PrivateWorker.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return PrivateWorker(
      id: docId,

      name:
          map['name'] ?? '',

      workType:
          map['work_type'] ?? '',

      phone:
          map['phone'] ?? '',

      notes:
          map['notes'],

      createdAt:
          DateTime.tryParse(
                map['created_at'] ??
                    '',
              ) ??
              DateTime.now(),
    );
  }
}