import 'package:flutter/material.dart';
import '../../sites/data/site_dao.dart';
import '../../sites/data/site_model.dart';
import '../../workers/data/worker_dao.dart';
import '../../workers/data/worker_model.dart';
import '../data/attendance_dao.dart';
import '../data/attendance_model.dart';
import '../data/attendance_month_summary.dart';

class AttendanceDayPage extends StatefulWidget {
  final int year, monthIndex;
  final String monthName;
  const AttendanceDayPage({super.key, required this.year, required this.monthIndex, required this.monthName});
  @override
  State<AttendanceDayPage> createState() => _AttendanceDayPageState();
}

class _AttendanceDayPageState extends State<AttendanceDayPage> {
  int _day = DateTime.now().day;
  final _workerDao = WorkerDao();
  final _siteDao = SiteDao();
  final _attendanceDao = AttendanceDao();
  List<SiteModel> _sites = [];
  bool _loadingSites = true;

  static const _shiftColors = {
    '6-6': Colors.green, '10-6': Colors.teal, '6-10': Colors.blue,
    '6-2': Colors.indigo, '10-2': Colors.purple, '2-6': Colors.cyan,
    'Absent': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    final max = DateUtils.getDaysInMonth(widget.year, widget.monthIndex + 1);
    if (_day > max) _day = max;
    _loadSites();
  }

  Future<void> _loadSites() async {
    final sites = await _siteDao.getAllSites();
    if (mounted) setState(() { _sites = sites; _loadingSites = false; });
  }

  double _wage(WorkerModel w, String type) => switch (type) {
    '6-6'  => w.rate6to6,  '10-6' => w.rate10to6, '6-10' => w.rate6to10,
    '6-2'  => w.rate6to2,  '10-2' => w.rate10to2, '2-6'  => w.rate2to6,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalDays = DateUtils.getDaysInMonth(widget.year, widget.monthIndex + 1);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('${widget.monthName} ${widget.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      body: _loadingSites
        ? const Center(child: CircularProgressIndicator())
        : Row(children: [
            // Day picker
            Container(
              width: 64,
              color: Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: totalDays,
                itemBuilder: (context, i) {
                  final d = i + 1;
                  final isSelected = _day == d;
                  final isToday = d == DateTime.now().day &&
                    widget.monthIndex + 1 == DateTime.now().month &&
                    widget.year == DateTime.now().year;
                  return GestureDetector(
                    onTap: () => setState(() => _day = d),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? cs.primary : isToday ? cs.primaryContainer : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(children: [
                        Text('$d', style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14,
                          color: isSelected ? Colors.white : isToday ? cs.onPrimaryContainer : null)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const VerticalDivider(width: 1),
            // Workers
            Expanded(
              child: StreamBuilder<List<WorkerModel>>(
                stream: _workerDao.watchWorkers(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                  final workers = snap.data ?? [];
                  if (workers.isEmpty) return const Center(child: Text('No workers added'));
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: _buildGroupedWorkers(workers),
                  );
                },
              ),
            ),
          ]),
    );
  }

  List<Widget> _buildGroupedWorkers(List<WorkerModel> workers) {
    final widgets = <Widget>[];
    final cs = Theme.of(context).colorScheme;
    for (final wt in ['Centring', 'Brickwork']) {
      final wtW = workers.where((w) => w.workType == wt).toList();
      if (wtW.isEmpty) continue;
      widgets.add(Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        color: cs.primaryContainer.withOpacity(0.3),
        child: Text(wt, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.primary)),
      ));
      for (final state in ['Telangana', 'Andhra', 'Bihar']) {
        final stateW = wtW.where((w) => w.state == state).toList();
        if (stateW.isEmpty) continue;
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
          child: Text(state, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        ));
        for (final role in ['Mason', 'Helper']) {
          final roleW = stateW.where((w) => w.role == role).toList();
          if (roleW.isEmpty) continue;
          widgets.add(Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 16, 0),
            child: Text(role, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ));
          for (final w in roleW) widgets.add(_workerAttendanceCard(w));
        }
      }
    }
    return widgets;
  }

  Widget _workerAttendanceCard(WorkerModel worker) {
    final date = DateTime(widget.year, widget.monthIndex + 1, _day);
    return FutureBuilder<AttendanceModel?>(
      future: _attendanceDao.getAttendanceForDay(workerId: worker.id!, date: date),
      builder: (context, snap) {
        final att = snap.data;
        final type = att?.attendanceType;
        final color = type != null ? _shiftColors[type] ?? Colors.grey : Colors.grey.shade300;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 18, backgroundColor: color.withOpacity(0.2),
              child: Text(worker.name[0].toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color.shade700)),
            ),
            title: Text(worker.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: att != null
              ? Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                    child: Text(type!, style: TextStyle(fontSize: 11, color: color.shade800, fontWeight: FontWeight.bold))),
                  if ((att.advance) > 0) ...[
                    const SizedBox(width: 6),
                    Text('Adv: ₹${att.advance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.orange)),
                  ],
                ])
              : const Text('Not marked', style: TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              if (att != null) IconButton(
                icon: const Icon(Icons.bar_chart_rounded, size: 20),
                tooltip: 'Monthly Summary',
                onPressed: () => _showSummary(worker),
              ),
              IconButton(
                icon: Icon(att != null ? Icons.edit_rounded : Icons.add_circle_outline_rounded,
                  size: 20, color: att != null ? Colors.deepOrange : Colors.green),
                tooltip: att != null ? 'Edit' : 'Mark Attendance',
                onPressed: () => _openDialog(worker),
              ),
            ]),
          ),
        );
      },
    );
  }

  void _showSummary(WorkerModel worker) async {
    final summary = await _attendanceDao.getMonthlySummary(
      workerId: worker.id!, year: widget.year, month: widget.monthIndex + 1);
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Row(children: [
        const Icon(Icons.bar_chart_rounded),
        const SizedBox(width: 8),
        Expanded(child: Text('${worker.name}\n${widget.monthName} ${widget.year}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
      ]),
      content: _summaryContent(summary),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ));
  }

  Widget _summaryContent(AttendanceMonthSummary s) {
    return SizedBox(width: 320, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (s.daysByType.isNotEmpty) ...[
        const Text('Days Worked', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        ...s.daysByType.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(children: [
            Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: (_shiftColors[e.key] ?? Colors.grey).withOpacity(0.6),
                borderRadius: BorderRadius.circular(2))),
            Text('${e.key}: ', style: const TextStyle(fontSize: 13)),
            Text('${e.value} days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        )),
        const Divider(),
      ],
      _summaryRow('Opening Balance', s.openingBalance),
      _summaryRow('Total Earned', s.totalEarned),
      _summaryRow('Total Advance Taken', s.totalAdvance),
      const Divider(),
      Row(children: [
        const Expanded(child: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        Text(
          s.balance > 0 ? '₹${s.balance.toStringAsFixed(0)} to give' :
          s.balance < 0 ? '₹${s.balance.abs().toStringAsFixed(0)} to receive' : 'Settled',
          style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 14,
            color: s.balance > 0 ? Colors.green : s.balance < 0 ? Colors.red : Colors.grey)),
      ]),
    ]));
  }

  Widget _summaryRow(String label, double value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey))),
      Text('₹${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    ]),
  );

  void _openDialog(WorkerModel worker) async {
    final date = DateTime(widget.year, widget.monthIndex + 1, _day);
    final saved = await _attendanceDao.getAttendanceForDay(workerId: worker.id!, date: date);

    if (!mounted) return;

    // Use local mutable state inside the dialog via StatefulBuilder
    String type = saved?.attendanceType ?? '6-6';
    double advance = saved?.advance ?? 0;
    String payment = saved?.paymentMode ?? 'Cash';
    SiteModel? site = (saved?.siteId != null && _sites.isNotEmpty)
      ? _sites.firstWhere((s) => s.id == saved!.siteId, orElse: () => _sites.first)
      : (_sites.isNotEmpty ? _sites.first : null);
    final advCtrl = TextEditingController(text: advance.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(children: [
            const Icon(Icons.access_time_rounded, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(worker.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ]),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${widget.monthName} $_day, ${widget.year}',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(labelText: 'Attendance / Shift', isDense: true),
              items: const ['6-6','10-6','6-10','6-2','10-2','2-6','Absent']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setDialogState(() => type = v!),
            ),
            const SizedBox(height: 12),
            if (_sites.isNotEmpty) DropdownButtonFormField<SiteModel>(
              value: site,
              decoration: const InputDecoration(labelText: 'Site Worked', isDense: true),
              items: _sites.map((s) => DropdownMenuItem(value: s, child: Text(s.siteName, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => setDialogState(() => site = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: advCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Advance Given (₹)', prefixText: '₹ ', isDense: true),
              onChanged: (v) => advance = double.tryParse(v) ?? 0,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: payment,
              decoration: const InputDecoration(labelText: 'Payment Mode', isDense: true),
              items: const ['Cash','Online','None']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setDialogState(() => payment = v!),
            ),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white),
              child: const Text('Save'),
              onPressed: () async {
                try {
                  final model = AttendanceModel(
                    workerId: worker.id!, siteId: site?.id,
                    date: date, attendanceType: type,
                    wage: _wage(worker, type), advance: double.tryParse(advCtrl.text) ?? 0,
                    paymentMode: payment, paymentRef: null, balanceAfter: 0,
                  );
                  await _attendanceDao.autoMarkAbsentIfMissed(workerId: worker.id!, currentDate: date);
                  await _attendanceDao.saveOrUpdateAttendance(model);
                  if (mounted) {
                    Navigator.pop(dialogContext);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Attendance saved!'), backgroundColor: Colors.green));
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
