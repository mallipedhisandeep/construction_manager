import '../../../core/database/db_helper.dart';
import 'site_elevation_model.dart';

class SiteElevationDao {
  final _db = DBHelper.instance;

  Future<void> insert(SiteElevationModel m) async {
    final db = await _db.database;
    await db.insert('site_elevations', m.toMap());
  }

  Future<List<SiteElevationModel>> getBySite(int siteId) async {
    final db = await _db.database;
    final res = await db.query(
      'site_elevations',
      where: 'site_id = ?',
      whereArgs: [siteId],
      orderBy: 'id DESC',
    );
    return res.map((e) => SiteElevationModel.fromMap(e)).toList();
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('site_elevations', where: 'id = ?', whereArgs: [id]);
  }
}