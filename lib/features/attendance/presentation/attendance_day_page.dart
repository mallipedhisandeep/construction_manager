import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../sites/data/site_dao.dart';
import '../../sites/data/site_model.dart';
import '../../workers/data/worker_dao.dart';
import '../../workers/data/worker_model.dart';
import '../data/attendance_dao.dart';
import '../data/attendance_model.dart';
import '../data/attendance_month_summary.dart';

class AttendanceDayPage extends ConsumerStatefulWidget {
  final int year, monthIndex;
  final String monthName;
  const AttendanceDayPage({super.key, required this.year, required this.monthIndex, required this.monthName});
  @override
  ConsumerState<AttendanceDayPage> createState() => _AttendanceDayPageState();
}

class _AttendanceDayPageState extends ConsumerState<AttendanceDayPage> {
  int _day = DateTime.now().day;
  final _workerDao = WorkerDao();
  final _siteDao   = SiteDao();
  final _attDao    = AttendanceDao();
  List<SiteModel> _sites = [];
  bool _loadingSites = true;

  // Fixed: use Map<String, Color> and avoid .shade variants on variable
  static const Map<String, Color> _shiftColors = {
    '6-6':  Color(0xFF2E7D32), // dark green
    '10-6': Color(0xFF00695C), // teal
    '6-10': Color(0xFF1565C0), // blue
    '6-2':  Color(0xFF283593), // indigo
    '10-2': Color(0xFF6A1B9A), // purple
    '2-6':  Color(0xFF00838F), // cyan
    'Absent': Color(0xFFC62828), // red
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
    final s = S(ref.watch(languageProvider));
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
            // Day selector column
            Container(
              width: 58,
              color: Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: totalDays,
                itemBuilder: (_, i) {
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
                      child: Text('$d', textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13,
                          color: isSelected ? Colors.white : isToday ? cs.primary : null)),
                    ),
                  );
                },
              ),
            ),
            const VerticalDivider(width: 1),

            // Workers list
            Expanded(
              child: StreamBuilder<List<WorkerModel>>(
                stream: _workerDao.watchWorkers(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('${s.errorPrefix}${snap.error}'));
                  }
                  final workers = snap.data ?? [];
                  if (workers.isEmpty) return Center(child: Text(s.noWorkers));
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: _buildGroupedWorkers(workers, s, cs),
                  );
                },
              ),
            ),
          ]),
    );
  }

  List<Widget> _buildGroupedWorkers(List<WorkerModel> workers, S s, ColorScheme cs) {
    final widgets = <Widget>[];
    for (final wt in ['Centring', 'Brickwork']) {
      final wtW = workers.where((w) => w.workType == wt).toList();
      if (wtW.isEmpty) continue;
      widgets.add(Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
        color: cs.primaryContainer.withOpacity(0.3),
        child: Text(wt, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.primary)),
      ));
      for (final state in ['Telangana', 'Andhra', 'Bihar']) {
        final stateW = wtW.where((w) => w.state == state).toList();
        if (stateW.isEmpty) continue;
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
          child: Text(state, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
        ));
        for (final role in ['Mason', 'Helper']) {
          final roleW = stateW.where((w) => w.role == role).toList();
          if (roleW.isEmpty) continue;
          widgets.add(Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 16, 0),
            child: Text(role, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ));
          for (final w in roleW) widgets.add(_workerCard(w, s, cs));
        }
      }
    }
    return widgets;
  }

  Widget _workerCard(WorkerModel worker, S s, ColorScheme cs) {
    final date = DateTime(widget.year, widget.monthIndex + 1, _day);
    return FutureBuilder<AttendanceModel?>(
      future: _attDao.getAttendanceForDay(workerId: worker.id!, date: date),
      builder: (context, snap) {
        final att = snap.data;
        final type = att?.attendanceType;
        // Fixed: use const Color map, no .shade variants on variable
        final color = type != null ? (_shiftColors[type] ?? Colors.grey) : Colors.grey.shade400;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.15),
              child: Text(worker.name[0].toUpperCase(),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
            ),
            title: Text(worker.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: att != null
              ? Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text(type!, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold))),
                  if (att.advance > 0) ...[
                    const SizedBox(width: 6),
                    Text('Adv: ₹${att.advance.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11, color: Colors.orange)),
                  ],
                ])
              : Text(s.notMarked, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              if (att != null) IconButton(
                icon: const Icon(Icons.bar_chart_rounded, size: 20),
                tooltip: s.monthlySummary,
                onPressed: () => _showSummary(worker, s),
              ),
              IconButton(
                icon: Icon(
                  att != null ? Icons.edit_rounded : Icons.add_circle_outline_rounded,
                  size: 20,
                  color: att != null ? Colors.deepOrange : Colors.green),
                tooltip: att != null ? s.edit : s.add,
                onPressed: () => _openDialog(worker, s, cs),
              ),
            ]),
          ),
        );
      },
    );
  }

  void _showSummary(WorkerModel worker, S s) async {
    final summary = await _attDao.getMonthlySummary(
      workerId: worker.id!, year: widget.year, month: widget.monthIndex + 1);
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('${worker.name} — ${widget.monthName}',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      content: _summaryContent(summary, s),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(s.close))],
    ));
  }

  Widget _summaryContent(AttendanceMonthSummary sum, S s) {
    final balance = sum.balance;
    final balanceColor = balance > 0 ? Colors.green : balance < 0 ? Colors.red : Colors.grey;
    return SizedBox(width: 300, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (sum.daysByType.isNotEmpty) ...[
        Text(s.daysWorked, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        ...sum.daysByType.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(children: [
            Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 8),
              color: _shiftColors[e.key]?.withOpacity(0.6) ?? Colors.grey),
            Text('${e.key}: ${e.value} days', style: const TextStyle(fontSize: 13)),
          ]),
        )),
        const Divider(),
      ],
      _sumRow(s.openingBal,   sum.openingBalance),
      _sumRow(s.totalEarned,  sum.totalEarned),
      _sumRow(s.totalAdvance, sum.totalAdvance),
      const Divider(),
      Row(children: [
        Expanded(child: Text(s.balance, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        Text(
          balance == 0 ? s.settled :
          balance > 0 ? '₹${balance.toStringAsFixed(0)} ${s.toGive}' :
                        '₹${balance.abs().toStringAsFixed(0)} ${s.toReceive}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: balanceColor)),
      ]),
    ]));
  }

  Widget _sumRow(String label, double value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey))),
      Text('₹${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    ]),
  );

  void _openDialog(WorkerModel worker, S s, ColorScheme cs) async {
    final date = DateTime(widget.year, widget.monthIndex + 1, _day);
    final saved = await _attDao.getAttendanceForDay(workerId: worker.id!, date: date);
    if (!mounted) return;

    String type   = saved?.attendanceType ?? '6-6';
    double advance = saved?.advance ?? 0;
    String payment = saved?.paymentMode ?? 'Cash';
    SiteModel? site = (saved?.siteId != null && _sites.isNotEmpty)
      ? _sites.firstWhere((s) => s.id == saved!.siteId, orElse: () => _sites.first)
      : (_sites.isNotEmpty ? _sites.first : null);
    final advCtrl = TextEditingController(text: advance == 0 ? '' : advance.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Row(children: [
            Icon(Icons.access_time_rounded, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(worker.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
          ]),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${widget.monthName} $_day, ${widget.year}',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              value: type,
              decoration: InputDecoration(labelText: s.shift, isDense: true),
              items: ['6-6','10-6','6-10','6-2','10-2','2-6','Absent']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setSt(() => type = v!),
            ),
            const SizedBox(height: 10),

            if (_sites.isNotEmpty) DropdownButtonFormField<SiteModel>(
              value: site,
              decoration: InputDecoration(labelText: s.siteWorked, isDense: true),
              items: _sites.map((s) => DropdownMenuItem(value: s,
                child: Text(s.siteName, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => setSt(() => site = v),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: advCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: s.advanceGiven, isDense: true),
              onChanged: (v) => advance = double.tryParse(v) ?? 0,
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: payment,
              decoration: InputDecoration(labelText: s.paymentMode, isDense: true),
              items: ['Cash','Online','None']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setSt(() => payment = v!),
            ),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(s.cancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white),
              child: Text(s.save),
              onPressed: () async {
                try {
                  final model = AttendanceModel(
                    workerId: worker.id!, siteId: site?.id, date: date,
                    attendanceType: type, wage: _wage(worker, type),
                    advance: double.tryParse(advCtrl.text) ?? 0,
                    paymentMode: payment, paymentRef: null, balanceAfter: 0,
                  );
                  await _attDao.autoMarkAbsentIfMissed(workerId: worker.id!, currentDate: date);
                  await _attDao.saveOrUpdateAttendance(model);
                  if (mounted) {
                    Navigator.pop(dialogCtx);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(s.attSaved), backgroundColor: Colors.green));
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${s.errorPrefix}$e'), backgroundColor: Colors.red));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
