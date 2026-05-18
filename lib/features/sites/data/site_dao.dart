import 'package:sqflite/sqflite.dart';
import '../../../core/database/db_helper.dart';
import 'site_model.dart';

class SiteDao {
  final _db = DBHelper.instance;

  Future<void> insertSite(SiteModel site) async {
    final db = await _db.database;

    print('INSERT SITE => ${site.toMap()}');

    await db.insert(
      'sites',
      site.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('SITE INSERTED');
  }

  Future<void> updateSite(SiteModel site) async {
    final db = await _db.database;

    await db.update(
      'sites',
      site.toMap(),
      where: 'id = ?',
      whereArgs: [site.id],
    );
  }

  Future<void> deleteSite(int id) async {
    final db = await _db.database;
    await db.delete('sites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SiteModel>> getAllSites() async {
    final db = await _db.database;
    final res = await db.query('sites', orderBy: 'site_name');

    print('SITES FROM DB => $res');

    return res.map((e) => SiteModel.fromMap(e)).toList();
  }

  Future<SiteModel?> getById(int id) async {
    final db = await _db.database;
    final res = await db.query(
      'sites',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (res.isEmpty) return null;
    return SiteModel.fromMap(res.first);
  }
}