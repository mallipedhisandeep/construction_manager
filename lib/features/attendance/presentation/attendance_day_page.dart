import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'attendance_worker_monthly_page.dart';

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

  // FIX: use 0.0 not 0 — switch expression return type must be double
  double _wage(WorkerModel w, String type) => switch (type) {
    '6-6'  => w.rate6to6,
    '10-6' => w.rate10to6,
    '6-10' => w.rate6to10,
    '6-2'  => w.rate6to2,
    '10-2' => w.rate10to2,
    '2-6'  => w.rate2to6,
    _      => 0.0,
  };

  @override
  Widget build(BuildContext context) {
    final s = S(ref.watch(languageProvider));
    final cs = Theme.of(context).colorScheme;
    final totalDays = DateUtils.getDaysInMonth(widget.year, widget.monthIndex + 1);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('${widget.monthName} ${widget.year}',
          style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      body: _loadingSites
        ? const Center(child: CircularProgressIndicator())
        : Row(children: [
            // Day column
            Container(
              width: 56,
              color: Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: totalDays,
                itemBuilder: (_, i) {
                  final d = i + 1;
                  final sel = _day == d;
                  final isToday = d == DateTime.now().day &&
                    widget.monthIndex + 1 == DateTime.now().month &&
                    widget.year == DateTime.now().year;
                  return GestureDetector(
                    onTap: () => setState(() => _day = d),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? cs.primary : isToday ? cs.primaryContainer : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('$d', textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13,
                          color: sel ? Colors.white : isToday ? cs.primary : Colors.grey.shade700)),
                    ),
                  );
                },
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: StreamBuilder<List<WorkerModel>>(
                stream: _workerDao.watchWorkers(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                  final workers = snap.data ?? [];
                  if (workers.isEmpty) return Center(child: Text(s.noWorkers));
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: _buildGrouped(workers, s, cs),
                  );
                },
              ),
            ),
          ]),
    );
  }

  List<Widget> _buildGrouped(List<WorkerModel> workers, S s, ColorScheme cs) {
    final widgets = <Widget>[];
    for (final wt in ['Centring', 'Brickwork']) {
      final wtW = workers.where((w) => w.workType == wt).toList();
      if (wtW.isEmpty) continue;
      widgets.add(Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
        color: cs.primaryContainer.withOpacity(0.3),
        child: Text(wt, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: cs.primary)),
      ));
      for (final state in ['Telangana', 'Andhra', 'Bihar']) {
        final stateW = wtW.where((w) => w.state == state).toList();
        if (stateW.isEmpty) continue;
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
          child: Text(state, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
        ));
        for (final role in ['Mason', 'Helper']) {
          final roleW = stateW.where((w) => w.role == role).toList();
          if (roleW.isEmpty) continue;
          widgets.add(Padding(
            padding: const EdgeInsets.fromLTRB(24, 2, 16, 0),
            child: Text(role, style: const TextStyle(fontSize: 11)),
          ));
          for (final w in roleW) widgets.add(_card(w, s, cs));
        }
      }
    }
    return widgets;
  }

  Widget _card(WorkerModel worker, S s, ColorScheme cs) {
    final date = DateTime(widget.year, widget.monthIndex + 1, _day);
    return FutureBuilder<AttendanceModel?>(
      future: _attDao.getAttendanceForDay(workerId: worker.id!, date: date),
      builder: (context, snap) {
        final att  = snap.data;
        final type = att?.attendanceType;
        final col  = type != null ? (_shiftColors[type] ?? Colors.grey) : Colors.grey.shade400;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 17, backgroundColor: col.withOpacity(0.15),
              child: Text(worker.name[0].toUpperCase(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: col))),
            title: Text(worker.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: att != null
              ? Wrap(spacing: 6, children: [
                  _tag(type!, col),
                  if (att.advance > 0) _tag('Adv ₹${att.advance.toStringAsFixed(0)}', Colors.orange),
                ])
              : Text(s.notMarked, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              if (att != null) IconButton(
                icon: const Icon(Icons.bar_chart_rounded, size: 18),
                visualDensity: VisualDensity.compact,
                onPressed: () => _showSummary(worker, s, cs),
              ),
              IconButton(
                icon: Icon(att != null ? Icons.edit_rounded : Icons.add_circle_outline_rounded,
                  size: 18, color: att != null ? cs.primary : Colors.green),
                visualDensity: VisualDensity.compact,
                onPressed: () => _openDialog(worker, s, cs),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _tag(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
    child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
  );

  void _showSummary(WorkerModel worker, S s, ColorScheme cs) async {
    final summary = await _attDao.getMonthlySummary(
      workerId: worker.id!, year: widget.year, month: widget.monthIndex + 1);
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('${worker.name}\n${widget.monthName} ${widget.year}',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      content: _summaryContent(summary, s),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(s.close)),
        ElevatedButton.icon(
          icon: const Icon(Icons.open_in_new_rounded, size: 16),
          label: const Text('Full Details'),
          style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) =>
              AttendanceWorkerMonthlyPage(
                worker: worker,
                year: widget.year,
                month: widget.monthIndex + 1,
                monthName: widget.monthName,
              )));
          },
        ),
      ],
    ));
  }

  Widget _summaryContent(AttendanceMonthSummary sum, S s) {
    final balance = sum.balance;
    final balColor = balance > 0 ? Colors.green : balance < 0 ? Colors.red : Colors.grey;
    return SizedBox(width: 280, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (sum.daysByType.isNotEmpty) ...[
        Text(s.daysWorked, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 4, children: sum.daysByType.entries.map((e) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (_shiftColors[e.key] ?? Colors.grey).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
          child: Text('${e.key}: ${e.value}d',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
              color: _shiftColors[e.key] ?? Colors.grey)),
        )).toList()),
        const Divider(height: 16),
      ],
      _row(s.openingBal,   '₹${sum.openingBalance.toStringAsFixed(0)}'),
      _row(s.totalEarned,  '₹${sum.totalEarned.toStringAsFixed(0)}'),
      _row(s.totalAdvance, '₹${sum.totalAdvance.toStringAsFixed(0)}'),
      const Divider(height: 12),
      Row(children: [
        Expanded(child: Text(s.balance, style: const TextStyle(fontWeight: FontWeight.bold))),
        Text(
          balance == 0 ? s.settled :
          balance > 0 ? '₹${balance.toStringAsFixed(0)} ${s.toGive}' :
                        '₹${balance.abs().toStringAsFixed(0)} ${s.toReceive}',
          style: TextStyle(fontWeight: FontWeight.bold, color: balColor)),
      ]),
    ]));
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    ]),
  );

  void _openDialog(WorkerModel worker, S s, ColorScheme cs) async {
    final date  = DateTime(widget.year, widget.monthIndex + 1, _day);
    final saved = await _attDao.getAttendanceForDay(workerId: worker.id!, date: date);
    if (!mounted) return;

    String type    = saved?.attendanceType ?? '6-6';
    double advance = saved?.advance ?? 0;
    String payment = saved?.paymentMode ?? 'Cash';
    SiteModel? site = (saved?.siteId != null && _sites.isNotEmpty)
      ? _sites.firstWhere((s) => s.id == saved!.siteId, orElse: () => _sites.first)
      : (_sites.isNotEmpty ? _sites.first : null);
    final advCtrl = TextEditingController(text: advance == 0 ? '' : advance.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(worker.name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.primary)),
            Text('${widget.monthName} $_day, ${widget.year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
          content: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(height: 12),
                // Shift chips
                Text(s.shift, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: ['6-6','10-6','6-10','6-2','10-2','2-6','Absent'].map((sh) {
                    final sel = type == sh;
                    final c = _shiftColors[sh] ?? Colors.grey;
                    return GestureDetector(
                      onTap: () => setSt(() => type = sh),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel ? c : c.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: sel ? c : c.withOpacity(0.3)),
                        ),
                        child: Text(sh, style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold,
                          color: sel ? Colors.white : c)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                if (_sites.isNotEmpty) ...[
                  DropdownButtonFormField<SiteModel>(
                    value: site,
                    isDense: true,
                    decoration: InputDecoration(labelText: s.siteWorked,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    items: _sites.map((s) => DropdownMenuItem(value: s,
                      child: Text(s.siteName, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) => setSt(() => site = v),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: advCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: s.advanceGiven,
                        prefixText: '₹ ',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: payment,
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: 'Mode',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: ['Cash','Online','None']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setSt(() => payment = v!),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dCtx), child: Text(s.cancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white),
              child: Text(s.save),
              onPressed: () async {
                try {
                  final model = AttendanceModel(
                    workerId: worker.id!, siteId: site?.id, date: date,
                    attendanceType: type, wage: _wage(worker, type),
                    advance: double.tryParse(advCtrl.text) ?? 0.0,
                    paymentMode: payment, paymentRef: null, balanceAfter: 0.0,
                  );
                  await _attDao.autoMarkAbsentIfMissed(workerId: worker.id!, currentDate: date);
                  await _attDao.saveOrUpdateAttendance(model);
                  if (mounted) {
                    Navigator.pop(dCtx);
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
