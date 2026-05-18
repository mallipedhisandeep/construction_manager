class SiteElevationModel {
  final int? id;
  final int siteId;
  final String filePath;
  final String createdAt;

  SiteElevationModel({
    this.id,
    required this.siteId,
    required this.filePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'site_id': siteId,
    'file_path': filePath,
    'created_at': createdAt,
  };

  factory SiteElevationModel.fromMap(Map<String, dynamic> map) {
    return SiteElevationModel(
      id: map['id'],
      siteId: map['site_id'],
      filePath: map['file_path'],
      createdAt: map['created_at'],
    );
  }
}