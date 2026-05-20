class SiteElevationModel {

  final String? id;

  final String siteId;

  final String fileName;

  final String filePath;

  final String createdAt;

  SiteElevationModel({

    this.id,

    required this.siteId,

    required this.fileName,

    required this.filePath,

    required this.createdAt,
  });

  // ==============================
  // TO MAP
  // ==============================

  Map<String, dynamic> toMap() {

    return {

      'site_id': siteId,

      'file_name': fileName,

      'file_path': filePath,

      'created_at': createdAt,
    };
  }

  // ==============================
  // FROM MAP
  // ==============================

  factory SiteElevationModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {

    return SiteElevationModel(

      id: documentId,

      siteId:
          map['site_id'] ?? '',

      fileName:
          map['file_name'] ?? '',

      filePath:
          map['file_path'] ?? '',

      createdAt:
          map['created_at'] ?? '',
    );
  }

  // ==============================
  // COPY WITH
  // ==============================

  SiteElevationModel copyWith({

    String? id,

    String? siteId,

    String? fileName,

    String? filePath,

    String? createdAt,

  }) {

    return SiteElevationModel(

      id: id ?? this.id,

      siteId:
          siteId ?? this.siteId,

      fileName:
          fileName ?? this.fileName,

      filePath:
          filePath ?? this.filePath,

      createdAt:
          createdAt ?? this.createdAt,
    );
  }
}