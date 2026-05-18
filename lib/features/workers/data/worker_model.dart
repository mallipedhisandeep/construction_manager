class WorkerModel {
  final int? id;
  final String name;
  final String phone;
  final String gender;
  final String state;
  final String role;
  final String workType;

  final double rate6to6;
  final double rate10to6;
  final double rate6to10;
  final double rate6to2;
  final double rate10to2;
  final double rate2to6;

  final String? notes;

  WorkerModel({
    this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.state,
    required this.role,
    required this.workType,
    required this.rate6to6,
    required this.rate10to6,
    required this.rate6to10,
    required this.rate6to2,
    required this.rate10to2,
    required this.rate2to6,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'gender': gender,
      'state': state,
      'role': role,
      'work_type': workType,
      'rate_6_6': rate6to6,
      'rate_10_6': rate10to6,
      'rate_6_10': rate6to10,
      'rate_6_2': rate6to2,
      'rate_10_2': rate10to2,
      'rate_2_6': rate2to6,
      'notes': notes,
    };
  }

  factory WorkerModel.fromMap(Map<String, dynamic> map) {
    return WorkerModel(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      gender: map['gender'],
      state: map['state'],
      role: map['role'],
      workType: map['work_type'],
      rate6to6: (map['rate_6_6'] as num).toDouble(),
      rate10to6: (map['rate_10_6'] as num).toDouble(),
      rate6to10: (map['rate_6_10'] as num).toDouble(),
      rate6to2: (map['rate_6_2'] as num).toDouble(),
      rate10to2: (map['rate_10_2'] as num).toDouble(),
      rate2to6: (map['rate_2_6'] as num).toDouble(),
      notes: map['notes'],
    );
  }
}