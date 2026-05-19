class AttendanceMonthSummary {

  final Map<String, int>
      daysByType;

  final double totalEarned;

  final double totalAdvance;

  final double openingBalance;

  final double balance;

  AttendanceMonthSummary({
    required this.daysByType,
    required this.totalEarned,
    required this.totalAdvance,
    required this.openingBalance,
    required this.balance,
  });
}