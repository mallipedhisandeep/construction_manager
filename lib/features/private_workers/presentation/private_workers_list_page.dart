import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/private_worker_dao.dart';
import '../data/private_worker_model.dart';
import 'add_edit_private_worker_page.dart';
import 'private_worker_details_page.dart';

class PrivateWorkersListPage extends StatefulWidget {
  const PrivateWorkersListPage({super.key});
  @override
  State<PrivateWorkersListPage> createState() => _PrivateWorkersListPageState();
}

class _PrivateWorkersListPageState extends State<PrivateWorkersListPage> {
  final PrivateWorkerDao _dao = PrivateWorkerDao();
  List<PrivateWorker> _workers = [];
  Map<String, PrivateWorkerSummary> _summaries = {};
  bool _loading = true;
  String _search = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final workers = await _dao.getAll();
      final summaries = <String, PrivateWorkerSummary>{};
      for (final w in workers) {
        if (w.id != null) summaries[w.id!] = await _dao.getSummary(w.id!);
      }
      if (mounted) setState(() { _workers = workers; _summaries = summaries; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<PrivateWorker> get _filtered {
    if (_search.trim().isEmpty) return _workers;
    final q = _search.toLowerCase();
    return _workers.where((w) =>
      w.name.toLowerCase().contains(q) ||
      w.workType.toLowerCase().contains(q) ||
      w.phone.contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Private Workers', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditPrivateWorkerPage()));
          if (ok == true) _load();
        },
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add'),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search contractors...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.engineering_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No contractors found', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _workerCard(filtered[i]),
                    ),
              ),
            ]),
          ),
    );
  }

  Widget _workerCard(PrivateWorker w) {
    final summary = _summaries[w.id];
    final balance = summary?.balance ?? 0;
    final balanceColor = balance > 0 ? Colors.green : balance < 0 ? Colors.red : Colors.grey;
    final balanceText = balance > 0
      ? 'To give: ₹${balance.toStringAsFixed(0)}'
      : balance < 0
        ? 'To receive: ₹${balance.abs().toStringAsFixed(0)}'
        : 'Settled';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final changed = await Navigator.push(context, MaterialPageRoute(
            builder: (_) => PrivateWorkerDetailsPage(worker: w)));
          if (changed == true) _load();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(
              radius: 24, backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(w.name[0].toUpperCase(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(w.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(w.workType, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              if (summary?.lastSite != null)
                Text('Last: ${summary!.lastSite}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: balanceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: Text(balanceText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: balanceColor)),
              ),
              const SizedBox(height: 6),
              if (w.phone.isNotEmpty) GestureDetector(
                onTap: () => launchUrl(Uri.parse('tel:${w.phone}')),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.call_rounded, size: 14, color: Colors.green.shade600),
                  const SizedBox(width: 4),
                  Text(w.phone, style: TextStyle(fontSize: 11, color: Colors.green.shade600)),
                ]),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
