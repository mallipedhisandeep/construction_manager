import 'package:flutter/foundation.dart';

import '../../../core/services/supabase_service.dart';

import 'attendance_model.dart';
import 'attendance_month_summary.dart';

class AttendanceDao {
  final SupabaseService _supabase =
      SupabaseService.instance;

  // =========================
  // GET ATTENDANCE FOR DAY
  // =========================

  Future<AttendanceModel?>
      getAttendanceForDay({
    required String workerId,
    required DateTime date,
  }) async {
    try {
      final dateKey =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

      final response =
          await _supabase.attendance
              .select()
              .eq(
                'worker_id',
                workerId,
              )
              .eq(
                'date_key',
                dateKey,
              )
              .limit(1);

      if (response.isEmpty) {
        return null;
      }

      final data =
          response.first;

      return AttendanceModel.fromMap(
        data,
        data['id'].toString(),
      );
    } catch (e) {
      debugPrint(
        'GET ATTENDANCE ERROR => $e',
      );

      return null;
    }
  }

  // =========================
  // GET BALANCE BEFORE DATE
  // =========================

  Future<double>
      getBalanceBeforeDate(
    String workerId,
    DateTime date,
  ) async {
    try {
      final response =
          await _supabase.attendance
              .select()
              .eq(
                'worker_id',
                workerId,
              )
              .lt(
                'date',
                DateTime(
                  date.year,
                  date.month,
                  date.day,
                ).toIso8601String(),
              )
              .order(
                'date',
                ascending: false,
              )
              .limit(1);

      if (response.isEmpty) {
        return 0;
      }

      final data =
          response.first;

      return ((data['balance_after'] ??
                  0)
              as num)
          .toDouble();
    } catch (e) {
      debugPrint(
        'BALANCE ERROR => $e',
      );

      return 0;
    }
  }

  // =========================
  // SAVE / UPDATE
  // =========================

  Future<void>
      saveOrUpdateAttendance(
    AttendanceModel attendance,
  ) async {
    try {
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
          await _supabase.attendance
              .select()
              .eq(
                'worker_id',
                corrected.workerId,
              )
              .eq(
                'date_key',
                corrected.dateKey,
              )
              .limit(1);

      if (existing.isNotEmpty) {
        final existingId =
            existing.first['id'];

        await _supabase.attendance
            .update(
              corrected.toMap(),
            )
            .eq(
              'id',
              existingId,
            );

        return;
      }

      await _supabase.attendance
          .insert(
        corrected.toMap(),
      );
    } catch (e) {
      debugPrint(
        'SAVE ATTENDANCE ERROR => $e',
      );
    }
  }

  // =========================
  // AUTO ABSENT
  // =========================

  Future<void>
      autoMarkAbsentIfMissed({
    required String workerId,
    required DateTime currentDate,
  }) async {
    try {
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
        attendanceType: 'Absent',
        wage: 0,
        advance: 0,
        paymentMode: 'None',
        paymentRef: null,
        balanceAfter: baseBalance,
      );

      await _supabase.attendance
          .insert(
        absent.toMap(),
      );
    } catch (e) {
      debugPrint(
        'AUTO ABSENT ERROR => $e',
      );
    }
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
    try {
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

      final response =
          await _supabase.attendance
              .select()
              .eq(
                'worker_id',
                workerId,
              )
              .gte(
                'date',
                monthStart
                    .toIso8601String(),
              )
              .lt(
                'date',
                monthEnd
                    .toIso8601String(),
              );

      double earned = 0;

      double advance = 0;

      final Map<String, int>
          daysByType = {};

      for (final r in response) {
        final type =
            r['attendance_type']
                as String;

        earned +=
            ((r['wage'] ?? 0)
                    as num)
                .toDouble();

        advance +=
            ((r['advance'] ?? 0)
                    as num)
                .toDouble();

        daysByType[type] =
            (daysByType[type] ??
                    0) +
                1;
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
        balance: balance,
      );
    } catch (e) {
      debugPrint(
        'MONTH SUMMARY ERROR => $e',
      );

      return AttendanceMonthSummary(
        daysByType: {},
        totalEarned: 0,
        totalAdvance: 0,
        openingBalance: 0,
        balance: 0,
      );
    }
  }
}