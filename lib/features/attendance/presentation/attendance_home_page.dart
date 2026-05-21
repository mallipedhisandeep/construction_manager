import 'package:flutter/material.dart';
import 'attendance_month_page.dart';

class AttendanceHomePage extends StatelessWidget {
  const AttendanceHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear + i);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          color: cs.primary.withOpacity(0.1),
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Icon(Icons.info_outline, color: cs.primary, size: 18),
            const SizedBox(width: 8),
            const Expanded(child: Text('Select a year to mark and view attendance',
              style: TextStyle(fontSize: 13, color: Colors.black87))),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: years.length,
            itemBuilder: (context, i) {
              final year = years[i];
              final isCurrent = year == currentYear;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCurrent ? cs.primary : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.calendar_year_outlined,
                      color: isCurrent ? Colors.white : Colors.grey.shade600),
                  ),
                  title: Text('Year $year',
                    style: TextStyle(fontWeight: FontWeight.bold, color: isCurrent ? cs.primary : null)),
                  subtitle: Text(isCurrent ? 'Current Year' : '$year attendance records',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCurrent ? cs.primary : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Open', style: TextStyle(
                      color: isCurrent ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.w500, fontSize: 13)),
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => AttendanceMonthPage(year: year))),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
