import 'package:sqflite/sqflite.dart';
import '../../../core/database/db_helper.dart';
import 'private_worker_payment_model.dart';

class PrivateWorkerPaymentDao {
  final _db = DBHelper.instance;

  Future<void> insert(PrivateWorkerPayment p) async {
    final db = await _db.database;
    await db.insert('private_worker_payments', p.toMap());
  }

  Future<List<PrivateWorkerPayment>> getByWorker(int workerId) async {
    final db = await _db.database;
    final res = await db.query(
      'private_worker_payments',
      where: 'worker_id = ?',
      whereArgs: [workerId],
      orderBy: 'payment_date DESC',
    );

    return res.map((e) => PrivateWorkerPayment.fromMap(e)).toList();
  }

  /// 🔥 BALANCE LOGIC (CORRECT)
  /// +ve → Dad should give worker
  /// -ve → Worker should give dad
  /// 0  → Settled
  Future<double> getBalance(int workerId) async {
    final db = await _db.database;

    final given = Sqflite.firstIntValue(
      await db.rawQuery(
        '''
            SELECT SUM(amount)
            FROM private_worker_payments
            WHERE worker_id = ?
              AND direction = 'dad_to_worker'
            ''',
        [workerId],
      ),
    ) ??
        0;

    final taken = Sqflite.firstIntValue(
      await db.rawQuery(
        '''
            SELECT SUM(amount)
            FROM private_worker_payments
            WHERE worker_id = ?
              AND direction = 'worker_to_dad'
            ''',
        [workerId],
      ),
    ) ??
        0;

    return given.toDouble() - taken.toDouble();
  }
}