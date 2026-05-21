import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import 'attendance_month_page.dart';

class AttendanceHomePage extends ConsumerWidget {
  const AttendanceHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S(ref.watch(languageProvider));
    final cs = Theme.of(context).colorScheme;
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear + i);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(s.attendance, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      body: Column(children: [
        Container(
          color: cs.primary.withOpacity(0.08),
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Icon(Icons.info_outline, color: cs.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'Select a year → month → day to mark attendance',
              style: TextStyle(fontSize: 13, color: cs.primary))),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: years.length,
            itemBuilder: (context, i) {
              final year = years[i];
              final isCurrent = year == currentYear;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCurrent ? cs.primary : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10)),
                    // Fixed: use Icons.calendar_month instead of non-existent calendar_year_outlined
                    child: Icon(Icons.calendar_month,
                      color: isCurrent ? Colors.white : Colors.grey.shade500, size: 22),
                  ),
                  title: Text('$year', style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18,
                    color: isCurrent ? cs.primary : null)),
                  subtitle: Text(isCurrent ? 'Current Year' : 'Year $year',
                    style: const TextStyle(fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrent ? cs.primary : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8)),
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
