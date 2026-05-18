import 'package:flutter/material.dart';
import 'attendance_day_page.dart';

class AttendanceMonthPage extends StatelessWidget {
  final int year;

  const AttendanceMonthPage({super.key, required this.year});

  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Year $year')),
      body: ListView.builder(
        itemCount: monthNames.length, // ✅ FIX 1
        itemBuilder: (context, index) {
          final month = monthNames[index]; // ✅ FIX 1

          return Card(
            child: ListTile(
              title: Text(month),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceDayPage(
                      year: year,
                      monthIndex: index,        // ✅ 0-based
                      monthName: month,         // ✅ FIX 2
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}