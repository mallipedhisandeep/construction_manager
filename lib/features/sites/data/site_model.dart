class SiteModel {
  final int? id;
  final String siteName;
  final String? location;
  final String? ownerName;
  final String? ownerPhone;
  final String? startDate;
  final double budget;
  final int floorsCount;
  final String status;
  final String? notes;

  SiteModel({
    this.id,
    required this.siteName,
    this.location,
    this.ownerName,
    this.ownerPhone,
    this.startDate,
    required this.budget,
    required this.floorsCount,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'site_name': siteName,
      'location': location,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'start_date': startDate,
      'budget': budget,
      'floors_count': floorsCount,
      'status': status,
      'notes': notes,
    };
  }

  factory SiteModel.fromMap(Map<String, dynamic> map) {
    return SiteModel(
      id: map['id'],
      siteName: map['site_name'],
      location: map['location'],
      ownerName: map['owner_name'],
      ownerPhone: map['owner_phone'],
      startDate: map['start_date'],
      budget: (map['budget'] as num).toDouble(),
      floorsCount: map['floors_count'] ?? 1,
      status: map['status'] ?? 'Active',
      notes: map['notes'],
    );
  }
}