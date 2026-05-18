import 'package:flutter/material.dart';
import 'attendance_month_page.dart';

class AttendanceHomePage extends StatelessWidget {
  const AttendanceHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final years = List.generate(5, (i) => 2026 + i);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: ListView.builder(
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          return Card(
            child: ListTile(
              title: Text('Year $year'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceMonthPage(year: year),
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