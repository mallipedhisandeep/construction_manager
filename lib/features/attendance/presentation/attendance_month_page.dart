import 'package:flutter/material.dart';
import 'attendance_day_page.dart';

class AttendanceMonthPage extends StatelessWidget {
  final int year;
  const AttendanceMonthPage({super.key, required this.year});

  static const months = ['January','February','March','April','May','June',
    'July','August','September','October','November','December'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Year $year', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.1),
        itemCount: months.length,
        itemBuilder: (context, i) {
          final isCurrent = year == now.year && i == now.month - 1;
          final isPast = DateTime(year, i + 1).isBefore(DateTime(now.year, now.month));
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => AttendanceDayPage(year: year, monthIndex: i, monthName: months[i]))),
            child: Card(
              elevation: isCurrent ? 4 : 2,
              color: isCurrent ? cs.primary : null,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${i + 1}', style: TextStyle(
                  fontSize: 11, color: isCurrent ? Colors.white70 : Colors.grey.shade500)),
                Text(months[i], textAlign: TextAlign.center, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold,
                  color: isCurrent ? Colors.white : null)),
                if (isCurrent) Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Current', style: TextStyle(fontSize: 10, color: Colors.white)),
                ),
                if (isPast && !isCurrent) Icon(Icons.check_circle_rounded,
                  size: 14, color: Colors.green.shade300),
              ]),
            ),
          );
        },
      ),
    );
  }
}
