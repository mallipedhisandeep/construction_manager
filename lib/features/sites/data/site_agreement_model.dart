import 'package:cloud_firestore/cloud_firestore.dart';

class SiteAgreementModel {
  final String? id;

  final String siteId;

  final String filePath;

  final String fileName;

  final Timestamp? createdAt;

  SiteAgreementModel({
    this.id,
    required this.siteId,
    required this.filePath,
    required this.fileName,
    this.createdAt,
  });

  // ==============================
  // TO MAP
  // ==============================

  Map<String, dynamic> toMap() {
    return {
      'site_id': siteId,

      'file_path': filePath,

      'file_name': fileName,

      'created_at':
          createdAt ??
              FieldValue.serverTimestamp(),
    };
  }

  // ==============================
  // FROM MAP
  // ==============================

  factory SiteAgreementModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return SiteAgreementModel(
      id: documentId,

      siteId:
          map['site_id'] ?? '',

      filePath:
          map['file_path'] ?? '',

      fileName:
          map['file_name'] ?? '',

      createdAt:
          map['created_at'],
    );
  }

  // ==============================
  // COPY WITH
  // ==============================

  SiteAgreementModel copyWith({
    String? id,
    String? siteId,
    String? filePath,
    String? fileName,
    Timestamp? createdAt,
  }) {
    return SiteAgreementModel(
      id: id ?? this.id,

      siteId:
          siteId ?? this.siteId,

      filePath:
          filePath ?? this.filePath,

      fileName:
          fileName ?? this.fileName,

      createdAt:
          createdAt ?? this.createdAt,
    );
  }
}