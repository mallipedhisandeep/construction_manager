class SiteElevationModel {

  final String? id;

  final String siteId;

  final String filePath;

  final String createdAt;

  SiteElevationModel({

    this.id,

    required this.siteId,

    required this.filePath,

    required this.createdAt,
  });

  // ==============================
  // TO MAP
  // ==============================

  Map<String, dynamic> toMap() {

    return {

      'site_id': siteId,

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

    String? filePath,

    String? createdAt,

  }) {

    return SiteElevationModel(

      id: id ?? this.id,

      siteId:
          siteId ?? this.siteId,

      filePath:
          filePath ?? this.filePath,

      createdAt:
          createdAt ?? this.createdAt,
    );
  }
}