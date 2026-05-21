import 'package:flutter/material.dart';
import '../data/site_dao.dart';
import '../data/site_model.dart';
import 'site_details_page.dart';
import 'site_form_page.dart';

class SitesListPage extends StatefulWidget {
  const SitesListPage({super.key});
  @override
  State<SitesListPage> createState() => _SitesListPageState();
}

class _SitesListPageState extends State<SitesListPage> {
  final SiteDao _dao = SiteDao();
  List<SiteModel> _sites = [];
  bool _loading = true;
  String _filter = 'All';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final s = await _dao.getAllSites();
      if (mounted) setState(() { _sites = s; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<SiteModel> get _filtered => _filter == 'All' ? _sites : _sites.where((s) => s.status == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = _sites.where((s) => s.status == 'Active').length;
    final completed = _sites.where((s) => s.status == 'Completed').length;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Sites', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final changed = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SiteFormPage()));
          if (changed == true) _load();
        },
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Add Site'),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: Column(children: [
              // Stats bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  _statPill('All', _sites.length, Colors.grey, _filter == 'All', () => setState(() => _filter = 'All')),
                  const SizedBox(width: 8),
                  _statPill('Active', active, Colors.green, _filter == 'Active', () => setState(() => _filter = 'Active')),
                  const SizedBox(width: 8),
                  _statPill('Completed', completed, Colors.blue, _filter == 'Completed', () => setState(() => _filter = 'Completed')),
                ]),
              ),
              Expanded(
                child: _filtered.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.location_city_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No ${_filter == 'All' ? '' : _filter.toLowerCase() + ' '}sites found',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _siteCard(_filtered[i]),
                    ),
              ),
            ]),
          ),
    );
  }

  Widget _statPill(String label, int count, Color color, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$label ($count)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
            color: selected ? color : Colors.grey.shade700)),
        ]),
      ),
    );
  }

  Widget _siteCard(SiteModel site) {
    final isActive = site.status == 'Active';
    final statusColor = isActive ? Colors.green : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final changed = await Navigator.push(context, MaterialPageRoute(
            builder: (_) => SiteDetailsPage(site: site)));
          if (changed == true) _load();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.location_city_rounded, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(site.siteName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (site.location != null && site.location!.isNotEmpty)
                  Text(site.location!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
                child: Text(site.status, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _infoChip(Icons.layers_rounded, '${site.floorsCount} Floors'),
              const SizedBox(width: 8),
              _infoChip(Icons.currency_rupee_rounded, '${(site.budget / 100000).toStringAsFixed(1)}L Budget'),
              if (site.ownerName != null && site.ownerName!.isNotEmpty) ...[
                const SizedBox(width: 8),
                _infoChip(Icons.person_outline_rounded, site.ownerName!),
              ],
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 13, color: Colors.grey.shade500),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
  ]);
}
