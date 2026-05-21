import 'package:flutter/material.dart';
import '../data/private_work_dao.dart';
import '../data/private_work_model.dart';
import '../../private_workers/data/private_worker_dao.dart';
import '../../private_workers/data/private_worker_model.dart';
import '../../sites/data/site_dao.dart';
import '../../sites/data/site_model.dart';

class AddEditPrivateWorkPage extends StatefulWidget {
  final PrivateWork? work;
  const AddEditPrivateWorkPage({super.key, this.work});
  @override
  State<AddEditPrivateWorkPage> createState() => _AddEditPrivateWorkPageState();
}

class _AddEditPrivateWorkPageState extends State<AddEditPrivateWorkPage> {
  final _formKey = GlobalKey<FormState>();
  final _dao = PrivateWorkDao();
  List<PrivateWorker> _workers = [];
  List<SiteModel> _sites = [];
  PrivateWorker? _worker;
  SiteModel? _site;
  late TextEditingController _price, _paid, _notes;
  String _status = 'Active';
  DateTime _date = DateTime.now();
  bool _loading = true, _saving = false;

  @override
  void initState() {
    super.initState();
    _price = TextEditingController(text: widget.work?.priceCharged.toString() ?? '');
    _paid  = TextEditingController(text: widget.work?.amountPaid.toString() ?? '');
    _notes = TextEditingController(text: widget.work?.notes ?? '');
    _status = widget.work?.status ?? 'Active';
    if (widget.work != null) _date = DateTime.tryParse(widget.work!.workDate) ?? DateTime.now();
    _loadData();
  }

  @override
  void dispose() { _price.dispose(); _paid.dispose(); _notes.dispose(); super.dispose(); }

  Future<void> _loadData() async {
    try {
      _workers = await PrivateWorkerDao().getAll();
      _sites = await SiteDao().getAllSites();
      if (widget.work != null) {
        try { _worker = _workers.firstWhere((w) => w.id == widget.work!.workerId); } catch (_) {}
        try { _site = _sites.firstWhere((s) => s.id == widget.work!.siteId); } catch (_) {}
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.work == null ? 'Add Private Work' : 'Edit Private Work',
          style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            DropdownButtonFormField<PrivateWorker>(
              value: _worker,
              decoration: const InputDecoration(labelText: 'Worker *'),
              items: _workers.map((w) => DropdownMenuItem(value: w, child: Text(w.name))).toList(),
              onChanged: (v) => setState(() => _worker = v),
              validator: (v) => v == null ? 'Select a worker' : null,
            ),
            const SizedBox(height: 12),
            if (_worker != null) Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                Icon(Icons.construction_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Text('Work Type: ${_worker!.workType}',
                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.w500)),
              ]),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SiteModel>(
              value: _site,
              decoration: const InputDecoration(labelText: 'Site *'),
              items: _sites.map((s) => DropdownMenuItem(value: s,
                child: Text(s.siteName, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => setState(() => _site = v),
              validator: (v) => v == null ? 'Select a site' : null,
            ),
            const SizedBox(height: 12),
            Card(child: ListTile(
              leading: Icon(Icons.calendar_today_rounded, color: cs.primary),
              title: Text('Date: ${_date.toIso8601String().split('T')[0]}'),
              trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              onTap: () async {
                final d = await showDatePicker(
                  context: context, firstDate: DateTime(2000), lastDate: DateTime(2100), initialDate: _date);
                if (d != null) setState(() => _date = d);
              },
            )),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _price, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price Charged (₹) *', prefixText: '₹ '),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                controller: _paid, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount Paid (₹)', prefixText: '₹ '),
              )),
            ]),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['Active','Completed'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) { if (v != null) setState(() => _status = v); },
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white),
              child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(widget.work == null ? 'Save Work Entry' : 'Update Work Entry', style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      )),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _worker == null || _site == null) return;
    setState(() => _saving = true);
    try {
      final work = PrivateWork(
        id: widget.work?.id,
        workerId: _worker!.id!, workerName: _worker!.name,
        workType: _worker!.workType, siteId: _site!.id!, siteName: _site!.siteName,
        workDate: _date.toIso8601String().split('T').first,
        priceCharged: double.tryParse(_price.text.trim()) ?? 0,
        amountPaid: double.tryParse(_paid.text.trim()) ?? 0,
        status: _status, notes: _notes.text.trim(),
        createdAt: widget.work?.createdAt ?? DateTime.now(),
      );
      if (widget.work == null) await _dao.insert(work);
      else await _dao.update(work);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Saved successfully!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
