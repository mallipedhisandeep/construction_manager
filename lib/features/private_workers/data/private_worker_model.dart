class PrivateWorker {
  final int? id;
  final String name;
  final String workType;
  final String phone;
  final String? notes;

  PrivateWorker({
    this.id,
    required this.name,
    required this.workType,
    required this.phone,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'work_type': workType,
    'phone': phone,
    'notes': notes,
  };

  factory PrivateWorker.fromMap(Map<String, dynamic> m) => PrivateWorker(
    id: m['id'],
    name: m['name'],
    workType: m['work_type'],
    phone: m['phone'],
    notes: m['notes'],
  );
}