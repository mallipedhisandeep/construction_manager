import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../data/private_work_dao.dart';
import '../data/private_work_model.dart';
import 'add_edit_private_work_page.dart';
import 'private_work_details_page.dart';

class PrivateWorkListPage extends ConsumerStatefulWidget {
  const PrivateWorkListPage({super.key});
  @override
  ConsumerState<PrivateWorkListPage> createState() => _PrivateWorkListPageState();
}

class _PrivateWorkListPageState extends ConsumerState<PrivateWorkListPage> {
  final _dao = PrivateWorkDao();
  List<PrivateWork> _works = [];
  bool _loading = true;
  String _search = '', _filter = 'All';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final w = await _dao.getAll();
      if (mounted) setState(() { _works = w; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  List<PrivateWork> get _filtered {
    var list = _works;
    if (_filter != 'All') list = list.where((w) => w.status == _filter).toList();
    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((w) =>
        w.workerName.toLowerCase().contains(q) ||
        w.siteName.toLowerCase().contains(q) ||
        w.workType.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(ref.watch(languageProvider));
    final cs = Theme.of(context).colorScheme;
    final filtered = _filtered;
    final totalBalance = _works.fold<double>(0, (sum, w) => sum + (w.priceCharged - w.amountPaid));

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(s.privateWork, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddEditPrivateWorkPage()));
          if (ok == true) _load();
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(s.addWork),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: Column(children: [
              Container(color: Colors.white, padding: const EdgeInsets.all(12), child: Column(children: [
                if (_works.isNotEmpty) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: totalBalance > 0 ? Colors.orange.withOpacity(0.08) : Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: totalBalance > 0 ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3))),
                  child: Row(children: [
                    Icon(Icons.currency_rupee_rounded,
                      color: totalBalance > 0 ? Colors.orange : Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      totalBalance > 0
                        ? '${s.pendingBalance}: ₹${totalBalance.toStringAsFixed(0)}'
                        : s.allSettled,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: totalBalance > 0 ? Colors.orange.shade800 : Colors.green.shade800)),
                  ]),
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: '${s.search}...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  onChanged: (v) => setState(() => _search = v),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Active', 'Completed'].map((f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f), selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f)),
                    )).toList(),
                  ),
                ),
              ])),
              Expanded(
                child: filtered.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.work_outline_rounded, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(s.noWork, style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final w = filtered[i];
                        final balance = w.priceCharged - w.amountPaid;
                        final sc = _statusColor(w.status);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final changed = await Navigator.push(context,
                                MaterialPageRoute(builder: (_) => PrivateWorkDetailsPage(work: w)));
                              if (changed == true) _load();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Expanded(child: Text(w.workerName,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: sc.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12)),
                                    child: Text(w.status,
                                      style: TextStyle(fontSize: 12, color: sc, fontWeight: FontWeight.bold))),
                                ]),
                                const SizedBox(height: 6),
                                Row(children: [
                                  Icon(Icons.construction_rounded, size: 13, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(w.workType, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.location_on_rounded, size: 13, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(w.siteName,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    overflow: TextOverflow.ellipsis)),
                                ]),
                                const SizedBox(height: 8),
                                Row(children: [
                                  _moneyTag('Charged', w.priceCharged, Colors.blue),
                                  const SizedBox(width: 8),
                                  _moneyTag('Paid', w.amountPaid, Colors.green),
                                  if (balance > 0) ...[
                                    const SizedBox(width: 8),
                                    _moneyTag('Due', balance, Colors.orange),
                                  ],
                                ]),
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ]),
          ),
    );
  }

  Widget _moneyTag(String label, double amount, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Column(children: [
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      // Fixed: don't use .shade700 on Color — use withOpacity instead
      Text('₹${amount.toStringAsFixed(0)}',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    ]),
  );
}
