import '../../../core/database/db_helper.dart';
import 'site_floor_file_model.dart';

class SiteFloorFileDao {
  final _db = DBHelper.instance;

  Future<List<SiteFloorFileModel>> getFiles(int siteId, int floorNo) async {
    final db = await _db.database;

    final res = await db.query(
      'site_floor_files',
      where: 'site_id = ? AND floor_no = ?',
      whereArgs: [siteId, floorNo],
      orderBy: 'id DESC',
    );

    return res.map((e) => SiteFloorFileModel.fromMap(e)).toList();
  }

  Future<int> countFiles(int siteId, int floorNo) async {
    final db = await _db.database;

    final res = await db.rawQuery(
      'SELECT COUNT(*) as c FROM site_floor_files WHERE site_id=? AND floor_no=?',
      [siteId, floorNo],
    );

    return (res.first['c'] as int);
  }

  Future<void> insert(SiteFloorFileModel model) async {
    final db = await _db.database;
    await db.insert('site_floor_files', model.toMap());
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('site_floor_files', where: 'id=?', whereArgs: [id]);
  }
}