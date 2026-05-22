import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../data/worker_dao.dart';
import '../data/worker_model.dart';
import 'add_worker_page.dart';
import 'worker_details_page.dart';

class WorkersListPage extends ConsumerStatefulWidget {
  const WorkersListPage({super.key});
  @override
  ConsumerState<WorkersListPage> createState() => _WorkersListPageState();
}

class _WorkersListPageState extends ConsumerState<WorkersListPage> {
  final WorkerDao _dao = WorkerDao();
  String _search = '';
  // FIX 8: single nullable filter — null means 'All'
  String? _filterType;   // null=All, 'Centring', 'Brickwork'
  String? _filterState;  // null=All, 'Telangana', 'Andhra', 'Bihar'

  // FIX: explicit MaterialColor map so .shade variants compile correctly
  static const Map<String, MaterialColor> _stateColors = {
    'Telangana': Colors.green,
    'Andhra':    Colors.blue,
    'Bihar':     Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    final s = S(ref.watch(languageProvider));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(s.workers, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async =>
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddWorkerPage())),
        icon: const Icon(Icons.person_add_rounded),
        label: Text(s.addWorker),
      ),
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(
              decoration: InputDecoration(
                hintText: s.searchWorkers,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 8),
            // FIX 8: Work type filter — label + chips, no 'All' label duplication
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text('${s.workType}: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              Wrap(spacing: 6, children: [null, 'Centring', 'Brickwork'].map((v) {
                final selected = _filterType == v;
                final label = v == null ? 'All' : v;
                return GestureDetector(
                  onTap: () => setState(() => _filterType = v),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected ? cs.primary : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? cs.primary : Colors.grey.shade300)),
                    child: Text(label, style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : Colors.grey.shade700)),
                  ),
                );
              }).toList()),
            ]),
            const SizedBox(height: 6),
            // State filter
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text('${s.state}: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              Wrap(spacing: 6, children: [null, 'Telangana', 'Andhra', 'Bihar'].map((v) {
                final selected = _filterState == v;
                final label = v == null ? 'All' : v;
                return GestureDetector(
                  onTap: () => setState(() => _filterState = v),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected ? cs.primary : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? cs.primary : Colors.grey.shade300)),
                    child: Text(label, style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : Colors.grey.shade700)),
                  ),
                );
              }).toList()),
            ]),
          ]),
        ),
        Expanded(
          child: StreamBuilder<List<WorkerModel>>(
            stream: _dao.watchWorkers(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 8),
                    Text('${s.errorPrefix}${snap.error}', textAlign: TextAlign.center),
                  ])));
              }
              var workers = snap.data ?? [];
              if (_search.isNotEmpty) {
                workers = workers.where((w) =>
                  w.name.toLowerCase().contains(_search.toLowerCase()) ||
                  w.phone.contains(_search)).toList();
              }
              if (_filterType  != null) workers = workers.where((w) => w.workType == _filterType).toList();
              if (_filterState != null) workers = workers.where((w) => w.state    == _filterState).toList();

              if (workers.isEmpty) {
                return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.groups_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(s.noWorkers, style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                ]));
              }

              final grouped = <String, List<WorkerModel>>{};
              for (final w in workers) grouped.putIfAbsent(w.workType, () => []).add(w);

              return ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  for (final entry in grouped.entries) ...[
                    _sectionHeader(entry.key, entry.value.length, cs),
                    ...entry.value.map((w) => _workerCard(w, s, cs)),
                  ],
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _sectionHeader(String title, int count, ColorScheme cs) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
    child: Row(children: [
      Container(width: 4, height: 18, decoration: BoxDecoration(
        color: cs.primary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(10)),
        child: Text('$count', style: TextStyle(fontSize: 11, color: cs.onPrimaryContainer, fontWeight: FontWeight.bold)),
      ),
    ]),
  );

  Widget _workerCard(WorkerModel w, S s, ColorScheme cs) {
    // Safe: map is Map<String, MaterialColor> so .shade100/.shade800 are valid
    final MaterialColor stateColor = _stateColors[w.state] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer, radius: 20,
          child: Text(w.name.isNotEmpty ? w.name[0].toUpperCase() : '?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onPrimaryContainer))),
        title: Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Row(children: [
            _chip(w.role,  Colors.grey.shade100,    Colors.grey.shade700),
            const SizedBox(width: 6),
            _chip(w.state, stateColor.shade100, stateColor.shade800),
          ]),
          const SizedBox(height: 3),
          Text('₹${w.rate6to6.toStringAsFixed(0)}/day',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (w.phone.isNotEmpty) IconButton(
            icon: const Icon(Icons.call_rounded, color: Colors.green, size: 20),
            onPressed: () => launchUrl(Uri.parse('tel:${w.phone}')),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ]),
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => WorkerDetailsPage(worker: w))),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(fontSize: 10, color: text, fontWeight: FontWeight.w500)),
  );
}
