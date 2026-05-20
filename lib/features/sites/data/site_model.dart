import 'package:cloud_firestore/cloud_firestore.dart';

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

  final Timestamp? createdAt;

  final Timestamp? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

  // ==============================
  // TO MAP
  // ==============================

  Map<String, dynamic> toMap() {
    return {
      'site_name': siteName.trim(),

      'site_name_search':
          siteName.toLowerCase().trim(),

      'location': location,

      'owner_name': ownerName,

      'owner_phone': ownerPhone,

      'start_date': startDate,

      'budget': budget,

      'floors_count': floorsCount,

      'status': status,

      'notes': notes,

      'created_at':
          createdAt ??
              FieldValue.serverTimestamp(),

      'updated_at':
          FieldValue.serverTimestamp(),
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

      createdAt:
          map['created_at'],

      updatedAt:
          map['updated_at'],
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
    Timestamp? createdAt,
    Timestamp? updatedAt,
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
          floorsCount ??
              this.floorsCount,

      status:
          status ?? this.status,

      notes:
          notes ?? this.notes,

      createdAt:
          createdAt ?? this.createdAt,

      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }
}