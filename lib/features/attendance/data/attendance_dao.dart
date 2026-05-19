import '../../../core/services/firebase_service.dart';

import 'attendance_model.dart';
import 'attendance_month_summary.dart';

class AttendanceDao {

  final FirebaseService _firebase =
      FirebaseService.instance;

  // ==============================
  // GET ATTENDANCE FOR DAY
  // ==============================

  Future<AttendanceModel?>
      getAttendanceForDay({

    required String workerId,

    required DateTime date,

  }) async {

    final dateKey =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final snapshot =
        await _firebase.attendance

            .where(
              'worker_id',
              isEqualTo: workerId,
            )

            .where(
              'date',
              isEqualTo: dateKey,
            )

            .limit(1)

            .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final doc =
        snapshot.docs.first;

    return AttendanceModel.fromMap(
      doc.data()
          as Map<String, dynamic>,
      doc.id,
    );
  }

  // ==============================
  // GET BALANCE BEFORE DATE
  // ==============================

  Future<double>
      getBalanceBeforeDate(
    String workerId,
    DateTime date,
  ) async {

    final dateKey =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final snapshot =
        await _firebase.attendance

            .where(
              'worker_id',
              isEqualTo: workerId,
            )

            .where(
              'date',
              isLessThan: dateKey,
            )

            .orderBy(
              'date',
              descending: true,
            )

            .limit(1)

            .get();

    if (snapshot.docs.isEmpty) {
      return 0;
    }

    final data =
        snapshot.docs.first.data()
            as Map<String, dynamic>;

    return (data['balance_after'] ?? 0)
        .toDouble();
  }

  // ==============================
  // SAVE OR UPDATE
  // ==============================

  Future<void>
      saveOrUpdateAttendance(
    AttendanceModel attendance,
  ) async {

    final baseBalance =
        await getBalanceBeforeDate(
      attendance.workerId,
      attendance.date,
    );

    final corrected =
        attendance.copyWith(
      balanceAfter:
          baseBalance +
              attendance.wage -
              attendance.advance,
    );

    final existing =
        await _firebase.attendance

            .where(
              'worker_id',
              isEqualTo:
                  corrected.workerId,
            )

            .where(
              'date',
              isEqualTo:
                  corrected.dateKey,
            )

            .limit(1)

            .get();

    // DELETE OLD
    for (final doc
        in existing.docs) {

      await _firebase.attendance
          .doc(doc.id)
          .delete();
    }

    // INSERT NEW
    await _firebase.attendance
        .add(corrected.toMap());
  }

  // ==============================
  // AUTO ABSENT
  // ==============================

  Future<void>
      autoMarkAbsentIfMissed({

    required String workerId,

    required DateTime currentDate,

  }) async {

    if (currentDate.day == 1) {
      return;
    }

    final prevDate =
        currentDate.subtract(
      const Duration(days: 1),
    );

    final existing =
        await getAttendanceForDay(
      workerId: workerId,
      date: prevDate,
    );

    if (existing != null) {
      return;
    }

    final baseBalance =
        await getBalanceBeforeDate(
      workerId,
      prevDate,
    );

    await _firebase.attendance.add({

      'worker_id': workerId,

      'site_id': null,

      'date':
          '${prevDate.year.toString().padLeft(4, '0')}-'
          '${prevDate.month.toString().padLeft(2, '0')}-'
          '${prevDate.day.toString().padLeft(2, '0')}',

      'attendance_type':
          'Absent',

      'wage': 0,

      'advance': 0,

      'payment_mode':
          'None',

      'payment_ref': null,

      'balance_after':
          baseBalance,
    });
  }

  // ==============================
  // MONTHLY SUMMARY
  // ==============================

  Future<AttendanceMonthSummary>
      getMonthlySummary({

    required String workerId,

    required int year,

    required int month,

  }) async {

    final monthStart =
        '$year-${month.toString().padLeft(2, '0')}-01';

    final nextMonth =
        month == 12
            ? 1
            : month + 1;

    final nextYear =
        month == 12
            ? year + 1
            : year;

    final monthEnd =
        '$nextYear-${nextMonth.toString().padLeft(2, '0')}-01';

    final openingBalance =
        await getBalanceBeforeDate(
      workerId,
      DateTime(year, month, 1),
    );

    final snapshot =
        await _firebase.attendance

            .where(
              'worker_id',
              isEqualTo: workerId,
            )

            .where(
              'date',
              isGreaterThanOrEqualTo:
                  monthStart,
            )

            .where(
              'date',
              isLessThan:
                  monthEnd,
            )

            .get();

    double earned = 0;

    double advance = 0;

    final Map<String, int>
        daysByType = {};

    for (final doc
        in snapshot.docs) {

      final r =
          doc.data()
              as Map<String, dynamic>;

      final type =
          r['attendance_type']
              as String;

      earned +=
          (r['wage'] ?? 0)
              .toDouble();

      advance +=
          (r['advance'] ?? 0)
              .toDouble();

      daysByType[type] =
          (daysByType[type] ?? 0) + 1;
    }

    final balance =
        openingBalance +
            earned -
            advance;

    return AttendanceMonthSummary(

      daysByType:
          daysByType,

      totalEarned:
          earned,

      totalAdvance:
          advance,

      openingBalance:
          openingBalance,

      balance:
          balance,
    );
  }
}