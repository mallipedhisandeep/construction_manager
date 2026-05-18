import '../../../core/database/db_helper.dart';
import 'worker_model.dart';

class WorkerDao {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<int> insertWorker(WorkerModel worker) async {
    final db = await _dbHelper.database;
    return await db.insert('workers', worker.toMap());
  }

  Future<List<WorkerModel>> getAllWorkers() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'workers',
      orderBy: 'work_type, state, role, name',
    );
    return result.map((e) => WorkerModel.fromMap(e)).toList();
  }
  Future<int> updateWorker(WorkerModel worker) async {
    final db = await _dbHelper.database;
    return await db.update(
      'workers',
      worker.toMap(),
      where: 'id = ?',
      whereArgs: [worker.id],
    );
  }
  Future<void> deleteWorker(int id) async {
    final db = await _dbHelper.database;
    await db.delete('workers', where: 'id = ?', whereArgs: [id]);
  }
}