import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firebase_service.dart';

import 'attendance_model.dart';
import 'attendance_month_summary.dart';

class AttendanceDao {
  final FirebaseService _firebase =
      FirebaseService.instance;

  // =========================
  // GET ATTENDANCE FOR DAY
  // =========================

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
              'date_key',
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
      doc.data(),
      doc.id,
    );
  }

  // =========================
  // GET BALANCE BEFORE DATE
  // =========================

  Future<double>
      getBalanceBeforeDate(
    String workerId,
    DateTime date,
  ) async {
    final snapshot =
        await _firebase.attendance

            .where(
              'worker_id',
              isEqualTo: workerId,
            )

            .where(
              'date',
              isLessThan:
                  Timestamp.fromDate(
                DateTime(
                  date.year,
                  date.month,
                  date.day,
                ),
              ),
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
        snapshot.docs.first.data();

    return (data['balance_after'] ??
            0)
        .toDouble();
  }

  // =========================
  // SAVE / UPDATE
  // =========================

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
              'date_key',
              isEqualTo:
                  corrected.dateKey,
            )

            .limit(1)

            .get();

    if (existing.docs.isNotEmpty) {
      final existingId =
          existing.docs.first.id;

      await _firebase.attendance
          .doc(existingId)
          .set(
            corrected.toMap(),
            SetOptions(
              merge: true,
            ),
          );

      return;
    }

    await _firebase.attendance
        .add(
      corrected.toMap(),
    );
  }

  // =========================
  // AUTO ABSENT
  // =========================

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

    final absent =
        AttendanceModel(
      workerId: workerId,

      siteId: null,

      date: prevDate,

      attendanceType:
          'Absent',

      wage: 0,

      advance: 0,

      paymentMode:
          'None',

      paymentRef: null,

      balanceAfter:
          baseBalance,
    );

    await _firebase.attendance
        .add(
      absent.toMap(),
    );
  }

  // =========================
  // MONTHLY SUMMARY
  // =========================

  Future<AttendanceMonthSummary>
      getMonthlySummary({
    required String workerId,
    required int year,
    required int month,
  }) async {
    final monthStart =
        DateTime(year, month, 1);

    final monthEnd =
        month == 12
            ? DateTime(
                year + 1,
                1,
                1,
              )
            : DateTime(
                year,
                month + 1,
                1,
              );

    final openingBalance =
        await getBalanceBeforeDate(
      workerId,
      monthStart,
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
                  Timestamp.fromDate(
                monthStart,
              ),
            )

            .where(
              'date',
              isLessThan:
                  Timestamp.fromDate(
                monthEnd,
              ),
            )

            .get();

    double earned = 0;

    double advance = 0;

    final Map<String, int>
        daysByType = {};

    for (final doc
        in snapshot.docs) {
      final r =
          doc.data();

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