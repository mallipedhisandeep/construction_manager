import '../../../core/database/db_helper.dart';
import 'private_work_model.dart';

class PrivateWorkDao {
  final _db = DBHelper.instance;

  Future<List<PrivateWork>> getAll() async {
    final db = await _db.database;
    final res = await db.query('private_work', orderBy: 'work_date DESC');
    return res.map((e) => PrivateWork.fromMap(e)).toList();
  }

  Future<void> insert(PrivateWork w) async {
    final db = await _db.database;
    await db.insert('private_work', w.toMap());
  }

  Future<void> update(PrivateWork w) async {
    final db = await _db.database;
    await db.update(
      'private_work',
      w.toMap(),
      where: 'id = ?',
      whereArgs: [w.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('private_work', where: 'id = ?', whereArgs: [id]);
  }
}