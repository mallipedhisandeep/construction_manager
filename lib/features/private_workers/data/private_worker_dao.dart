import '../../../core/database/db_helper.dart';
import 'private_worker_model.dart';

class PrivateWorkerDao {
  final _db = DBHelper.instance;

  Future<List<PrivateWorker>> getAll() async {
    final db = await _db.database;
    final res = await db.query('private_workers', orderBy: 'name');
    return res.map((e) => PrivateWorker.fromMap(e)).toList();
  }

  Future<void> insert(PrivateWorker w) async {
    final db = await _db.database;
    await db.insert('private_workers', w.toMap());
  }

  Future<void> update(PrivateWorker w) async {
    final db = await _db.database;
    await db.update(
      'private_workers',
      w.toMap(),
      where: 'id = ?',
      whereArgs: [w.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('private_workers', where: 'id = ?', whereArgs: [id]);
  }

  // ✅ SUMMARY (LAST SITE + DATE + BALANCE)
  Future<PrivateWorkerSummary> getSummary(int workerId) async {
    final db = await _db.database;

    final lastWork = await db.rawQuery('''
      SELECT site_name, work_date
      FROM private_work
      WHERE worker_id = ?
      ORDER BY work_date DESC
      LIMIT 1
    ''', [workerId]);

    final charged = await db.rawQuery(
        'SELECT SUM(price_charged) total FROM private_work WHERE worker_id = ?',
        [workerId]);

    final initialPaid = await db.rawQuery(
        'SELECT SUM(amount_paid) total FROM private_work WHERE worker_id = ?',
        [workerId]);

    final payments = await db.rawQuery('''
      SELECT direction, SUM(amount) total
      FROM private_worker_payments
      WHERE worker_id = ?
      GROUP BY direction
    ''', [workerId]);

    double balance = 0;
    balance += (charged.first['total'] ?? 0) as num;
    balance -= (initialPaid.first['total'] ?? 0) as num;

    for (final p in payments) {
      if (p['direction'] == 'dad_to_worker') {
        balance -= (p['total'] as num);
      } else {
        balance += (p['total'] as num);
      }
    }

    return PrivateWorkerSummary(
      lastSite: lastWork.isEmpty ? null : lastWork.first['site_name'] as String,
      lastDate: lastWork.isEmpty ? null : lastWork.first['work_date'] as String,
      balance: balance.toDouble(),
    );
  }
}

class PrivateWorkerSummary {
  final String? lastSite;
  final String? lastDate;
  final double balance;

  PrivateWorkerSummary({
    this.lastSite,
    this.lastDate,
    required this.balance,
  });
}