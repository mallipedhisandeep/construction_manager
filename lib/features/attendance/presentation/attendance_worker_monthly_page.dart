import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../workers/data/worker_model.dart';

class AttendanceWorkerMonthlyPage extends StatefulWidget {
  final WorkerModel worker;
  final int year, month;
  final String monthName;
  const AttendanceWorkerMonthlyPage({
    super.key,
    required this.worker,
    required this.year,
    required this.month,
    required this.monthName,
  });
  @override
  State<AttendanceWorkerMonthlyPage> createState() => _State();
}

class _State extends State<AttendanceWorkerMonthlyPage> {
  List<Map<String, dynamic>> _records = [];
  bool _loading = true;

  static const Map<String, Color> _shiftColors = {
    '6-6':   Color(0xFF2E7D32),
    '10-6':  Color(0xFF00695C),
    '6-10':  Color(0xFF1565C0),
    '6-2':   Color(0xFF283593),
    '10-2':  Color(0xFF6A1B9A),
    '2-6':   Color(0xFF00838F),
    'Absent':Color(0xFFC62828),
  };

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final client = Supabase.instance.client;
      // Get attendance records for this worker in this month
      final response = await client
          .from('attendance')
          .select('*, sites(site_name)')
          .eq('worker_id', widget.worker.id!)
          .gte('date', DateTime(widget.year, widget.month, 1).toIso8601String())
          .lt('date', DateTime(widget.year, widget.month + 1, 1).toIso8601String())
          .order('date', ascending: true);

      if (mounted) setState(() {
        _records = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Calculate totals
    double totalEarned  = 0, totalAdvance = 0;
    int workedDays = 0;
    for (final r in _records) {
      final type = r['attendance_type'] as String? ?? '';
      if (type != 'Absent') {
        totalEarned += ((r['wage'] ?? 0) as num).toDouble();
        workedDays++;
      }
      totalAdvance += ((r['advance'] ?? 0) as num).toDouble();
    }
    final balance = totalEarned - totalAdvance;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.worker.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text('${widget.monthName} ${widget.year}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ]),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(children: [
            // Summary bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                _summaryTile('Days', '$workedDays', Colors.blue),
                _summaryTile('Earned', '₹${totalEarned.toStringAsFixed(0)}', Colors.green),
                _summaryTile('Advance', '₹${totalAdvance.toStringAsFixed(0)}', Colors.orange),
                _summaryTile('Balance',
                  balance >= 0 ? '₹${balance.toStringAsFixed(0)}' : '-₹${balance.abs().toStringAsFixed(0)}',
                  balance >= 0 ? Colors.green : Colors.red),
              ]),
            ),
            const Divider(height: 1),

            // Records list
            Expanded(
              child: _records.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text('No records for ${widget.monthName}',
                      style: TextStyle(color: Colors.grey.shade500)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _records.length,
                    itemBuilder: (_, i) {
                      final r = _records[i];
                      final type = r['attendance_type'] as String? ?? 'Absent';
                      final date = DateTime.tryParse(r['date'] ?? '');
                      final wage = ((r['wage'] ?? 0) as num).toDouble();
                      final adv  = ((r['advance'] ?? 0) as num).toDouble();
                      final site = r['sites'] != null
                        ? (r['sites'] as Map)['site_name'] as String? ?? ''
                        : '';
                      final col = _shiftColors[type] ?? Colors.grey;
                      final isAbsent = type == 'Absent';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(children: [
                            // Day number
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: col.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8)),
                              child: Center(child: Text(
                                '${date?.day ?? '?'}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: col))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: col.withOpacity(isAbsent ? 0.08 : 0.12),
                                    borderRadius: BorderRadius.circular(6)),
                                  child: Text(type, style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold, color: col))),
                                if (site.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.location_on_rounded, size: 12, color: Colors.grey.shade400),
                                  Expanded(child: Text(site, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600))),
                                ],
                              ]),
                              if (!isAbsent) ...[
                                const SizedBox(height: 4),
                                Row(children: [
                                  Text('Earned: ₹${wage.toStringAsFixed(0)}',
                                    style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
                                  if (adv > 0) ...[
                                    const SizedBox(width: 12),
                                    Text('Adv: ₹${adv.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w500)),
                                  ],
                                ]),
                              ],
                            ])),
                            // Day of week
                            if (date != null) Text(
                              _dayName(date.weekday),
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                          ]),
                        ),
                      );
                    },
                  ),
            ),
          ]),
    );
  }

  Widget _summaryTile(String label, String value, Color color) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
  ]));

  String _dayName(int wd) => ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][wd - 1];
}
