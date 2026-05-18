class SiteFloorFileModel {
  final int? id;
  final int siteId;
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

  Map<String, dynamic> toMap() => {
    'id': id,
    'site_id': siteId,
    'floor_no': floorNo,
    'file_name': fileName,
    'file_path': filePath,
    'uploaded_at': uploadedAt,
  };

  factory SiteFloorFileModel.fromMap(Map<String, dynamic> map) {
    return SiteFloorFileModel(
      id: map['id'],
      siteId: map['site_id'],
      floorNo: map['floor_no'],
      fileName: map['file_name'],
      filePath: map['file_path'],
      uploadedAt: map['uploaded_at'],
    );
  }
}