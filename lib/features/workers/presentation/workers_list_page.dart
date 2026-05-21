import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/worker_dao.dart';
import '../data/worker_model.dart';
import 'add_worker_page.dart';
import 'worker_details_page.dart';

class WorkersListPage extends StatefulWidget {
  const WorkersListPage({super.key});
  @override
  State<WorkersListPage> createState() => _WorkersListPageState();
}

class _WorkersListPageState extends State<WorkersListPage> {
  final WorkerDao _dao = WorkerDao();
  String _search = '';
  String _filterType = 'All';
  String _filterState = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Workers', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddWorkerPage()));
        },
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Worker'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search workers...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _filterChips(['All','Centring','Brickwork'], _filterType, (v) => setState(() => _filterType = v))),
                    const SizedBox(width: 8),
                    Expanded(child: _filterChips(['All','Telangana','Andhra','Bihar'], _filterState, (v) => setState(() => _filterState = v))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<WorkerModel>>(
              stream: _dao.watchWorkers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 8),
                    Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                  ]));
                }
                var workers = snapshot.data ?? [];
                if (_search.isNotEmpty) workers = workers.where((w) => w.name.toLowerCase().contains(_search.toLowerCase()) || w.phone.contains(_search)).toList();
                if (_filterType != 'All') workers = workers.where((w) => w.workType == _filterType).toList();
                if (_filterState != 'All') workers = workers.where((w) => w.state == _filterState).toList();

                if (workers.isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.groups_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(_search.isNotEmpty ? 'No workers match your search' : 'No workers added yet',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                  ]));
                }

                // Group by workType
                final grouped = <String, List<WorkerModel>>{};
                for (final w in workers) {
                  grouped.putIfAbsent(w.workType, () => []).add(w);
                }

                return ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    for (final entry in grouped.entries) ...[
                      _sectionHeader(entry.key, entry.value.length),
                      ...entry.value.map((w) => _workerCard(w)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChips(List<String> options, String selected, ValueChanged<String> onSelect) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((o) => Padding(
          padding: const EdgeInsets.only(right: 6),
          child: ChoiceChip(
            label: Text(o, style: const TextStyle(fontSize: 12)),
            selected: selected == o,
            onSelected: (_) => onSelect(o),
            visualDensity: VisualDensity.compact,
          ),
        )).toList(),
      ),
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(2),
        )),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
          child: Text('$count', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _workerCard(WorkerModel w) {
    final stateColor = {'Telangana': Colors.green, 'Andhra': Colors.blue, 'Bihar': Colors.orange}[w.state] ?? Colors.grey;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          radius: 24,
          child: Text(w.name.isNotEmpty ? w.name[0].toUpperCase() : '?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer)),
        ),
        title: Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Row(children: [
            _chip(w.role, Colors.grey.shade100, Colors.grey.shade700),
            const SizedBox(width: 6),
            _chip(w.state, stateColor.withOpacity(0.1), stateColor.shade700),
          ]),
          const SizedBox(height: 4),
          Text('₹${w.rate6to6.toStringAsFixed(0)}/day (6-6)',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (w.phone.isNotEmpty) IconButton(
            icon: const Icon(Icons.call_rounded, color: Colors.green),
            onPressed: () async => await launchUrl(Uri.parse('tel:${w.phone}')),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ]),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerDetailsPage(worker: w))),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 11, color: text, fontWeight: FontWeight.w500)),
    );
  }
}
