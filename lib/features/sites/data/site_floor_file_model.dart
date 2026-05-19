class SiteFloorFileModel {

  final String? id;

  final String siteId;

  final int floorNo;

  final String fileName;

  final String filePath;

  final String uploadedAt;

  SiteFloorFileModel({

    this.id,

    required this.siteId,

    required this.floorNo,

    required this.fileName,

    required this.filePath,

    required this.uploadedAt,
  });

  // ==============================
  // TO MAP
  // ==============================

  Map<String, dynamic> toMap() {

    return {

      'site_id': siteId,

      'floor_no': floorNo,

      'file_name': fileName,

      'file_path': filePath,

      'uploaded_at': uploadedAt,
    };
  }

  // ==============================
  // FROM MAP
  // ==============================

  factory SiteFloorFileModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {

    return SiteFloorFileModel(

      id: documentId,

      siteId:
          map['site_id'] ?? '',

      floorNo:
          map['floor_no'] ?? 0,

      fileName:
          map['file_name'] ?? '',

      filePath:
          map['file_path'] ?? '',

      uploadedAt:
          map['uploaded_at'] ?? '',
    );
  }

  // ==============================
  // COPY WITH
  // ==============================

  SiteFloorFileModel copyWith({

    String? id,

    String? siteId,

    int? floorNo,

    String? fileName,

    String? filePath,

    String? uploadedAt,

  }) {

    return SiteFloorFileModel(

      id: id ?? this.id,

      siteId:
          siteId ?? this.siteId,

      floorNo:
          floorNo ?? this.floorNo,

      fileName:
          fileName ?? this.fileName,

      filePath:
          filePath ?? this.filePath,

      uploadedAt:
          uploadedAt ?? this.uploadedAt,
    );
  }
}