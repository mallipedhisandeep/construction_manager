class SiteAgreementModel {
  final int? id;
  final int siteId;
  final String filePath;
  final String fileName;
  final String createdAt;

  SiteAgreementModel({
    this.id,
    required this.siteId,
    required this.filePath,
    required this.fileName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'site_id': siteId,
      'file_path': filePath,
      'file_name': fileName,
      'created_at': createdAt,
    };
  }

  factory SiteAgreementModel.fromMap(Map<String, dynamic> map) {
    return SiteAgreementModel(
      id: map['id'],
      siteId: map['site_id'],
      filePath: map['file_path'],
      fileName: map['file_name'],
      createdAt: map['created_at'],
    );
  }
}