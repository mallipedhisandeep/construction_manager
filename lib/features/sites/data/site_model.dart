class SiteModel {

  final String? id;

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

  // ==============================
  // TO MAP
  // ==============================

  Map<String, dynamic> toMap() {

    return {

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

  // ==============================
  // FROM MAP
  // ==============================

  factory SiteModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {

    return SiteModel(

      id: documentId,

      siteName:
          map['site_name'] ?? '',

      location:
          map['location'],

      ownerName:
          map['owner_name'],

      ownerPhone:
          map['owner_phone'],

      startDate:
          map['start_date'],

      budget:
          (map['budget'] ?? 0)
              .toDouble(),

      floorsCount:
          map['floors_count'] ?? 1,

      status:
          map['status'] ??
              'Active',

      notes:
          map['notes'],
    );
  }

  // ==============================
  // COPY WITH
  // ==============================

  SiteModel copyWith({

    String? id,

    String? siteName,

    String? location,

    String? ownerName,

    String? ownerPhone,

    String? startDate,

    double? budget,

    int? floorsCount,

    String? status,

    String? notes,

  }) {

    return SiteModel(

      id: id ?? this.id,

      siteName:
          siteName ?? this.siteName,

      location:
          location ?? this.location,

      ownerName:
          ownerName ?? this.ownerName,

      ownerPhone:
          ownerPhone ?? this.ownerPhone,

      startDate:
          startDate ?? this.startDate,

      budget:
          budget ?? this.budget,

      floorsCount:
          floorsCount ?? this.floorsCount,

      status:
          status ?? this.status,

      notes:
          notes ?? this.notes,
    );
  }
}