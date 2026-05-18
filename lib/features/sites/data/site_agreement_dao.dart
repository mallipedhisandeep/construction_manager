import '../../../core/database/db_helper.dart';
import 'site_agreement_model.dart';

class SiteAgreementDao {
  final _db = DBHelper.instance;

  Future<void> insertAgreement(SiteAgreementModel agreement) async {
    final db = await _db.database;
    await db.insert('site_agreements', agreement.toMap());
  }

  Future<List<SiteAgreementModel>> getBySite(int siteId) async {
    final db = await _db.database;
    final res = await db.query(
      'site_agreements',
      where: 'site_id = ?',
      whereArgs: [siteId],
      orderBy: 'created_at DESC',
    );
    return res.map((e) => SiteAgreementModel.fromMap(e)).toList();
  }

  Future<void> deleteAgreement(int id) async {
    final db = await _db.database;
    await db.delete(
      'site_agreements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}