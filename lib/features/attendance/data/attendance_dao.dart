import 'package:sqflite/sqflite.dart';
import '../../../core/database/db_helper.dart';
import 'attendance_model.dart';
import 'attendance_month_summary.dart';

class AttendanceDao {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<AttendanceModel?> getAttendanceForDay({
    required int workerId,
    required DateTime date,
  }) async {
    final db = await _dbHelper.database;
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final result = await db.query(
      'attendance',
      where: 'worker_id = ? AND date = ?',
      whereArgs: [workerId, dateKey],
    );

    if (result.isNotEmpty) {
      return AttendanceModel.fromMap(result.first);
    }
    return null;
  }

  Future<double> getBalanceBeforeDate(int workerId, DateTime date) async {
    final db = await _dbHelper.database;
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final result = await db.rawQuery('''
      SELECT balance_after FROM attendance
      WHERE worker_id = ? AND date < ?
      ORDER BY date DESC
      LIMIT 1
    ''', [workerId, dateKey]);

    if (result.isNotEmpty) {
      return (result.first['balance_after'] as num).toDouble();
    }
    return 0;
  }


  Future<void> saveOrUpdateAttendance(AttendanceModel attendance) async {
    final db = await _dbHelper.database;
    final baseBalance =
    await getBalanceBeforeDate(attendance.workerId, attendance.date);
    final corrected = attendance.copyWith(
      balanceAfter: baseBalance + attendance.wage - attendance.advance,
    );

    await db.delete(
      'attendance',
      where: 'worker_id = ? AND date = ?',
      whereArgs: [corrected.workerId, corrected.dateKey],
    );

    await db.insert('attendance', corrected.toMap());
  }

  Future<void> autoMarkAbsentIfMissed({
    required int workerId,
    required DateTime currentDate,
  }) async {
    if (currentDate.day == 1) return;

    final db = await _dbHelper.database;
    final prevDate = currentDate.subtract(const Duration(days: 1));
    final prevDateKey =
        '${prevDate.year}-${prevDate.month.toString().padLeft(2, '0')}-${prevDate.day.toString().padLeft(2, '0')}';
    final existing = await db.query(
      'attendance',
      where: 'worker_id = ? AND date = ?',
      whereArgs: [workerId, prevDateKey],
    );

    if (existing.isNotEmpty) return;

    final baseBalance =
    await getBalanceBeforeDate(workerId, prevDate);
    await db.insert('attendance', {
      'worker_id': workerId,
      'site_id': null,
      'date': prevDateKey,
      'attendance_type': 'Absent',
      'wage': 0,
      'advance': 0,
      'payment_mode': 'None',
      'payment_ref': null,
      'balance_after': baseBalance,
    });
  }

  Future<AttendanceMonthSummary> getMonthlySummary({
    required int workerId,
    required int year,
    required int month, // 1-based
  }) async {
    final db = await _dbHelper.database;
    final monthStart = '$year-${month.toString().padLeft(2, '0')}-01';
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final monthEnd = '$nextYear-${nextMonth.toString().padLeft(2, '0')}-01';
    final openingResult = await db.rawQuery('''
      SELECT balance_after FROM attendance
      WHERE worker_id = ? AND date < ?
      ORDER BY date DESC
      LIMIT 1
    ''', [workerId, monthStart]);
    final openingBalance = openingResult.isNotEmpty
        ? (openingResult.first['balance_after'] as num).toDouble()
        : 0.0;
    final records = await db.query(
      'attendance',
      where: 'worker_id = ? AND date >= ? AND date < ?',
      whereArgs: [workerId, monthStart, monthEnd],
    );

    double earned = 0;
    double advance = 0;
    final Map<String, int> daysByType = {};

    for (final r in records) {
      final type = r['attendance_type'] as String;
      earned += (r['wage'] as num).toDouble();
      advance += (r['advance'] as num).toDouble();
      daysByType[type] = (daysByType[type] ?? 0) + 1;
    }

    final balance = openingBalance + earned - advance;

    return AttendanceMonthSummary(
      daysByType: daysByType,
      totalEarned: earned,
      totalAdvance: advance,
      openingBalance: openingBalance,
      balance: balance,
    );
  }
}