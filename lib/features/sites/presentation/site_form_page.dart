import 'package:flutter/material.dart';
import '../data/site_dao.dart';
import '../data/site_model.dart';

class SiteFormPage extends StatefulWidget {
  final SiteModel? site;
  const SiteFormPage({super.key, this.site});
  @override
  State<SiteFormPage> createState() => _SiteFormPageState();
}

class _SiteFormPageState extends State<SiteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final SiteDao _dao = SiteDao();
  late final TextEditingController _name, _location, _owner, _ownerPhone, _budget, _floors, _notes;
  String _status = 'Active';
  DateTime? _startDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.site;
    _name       = TextEditingController(text: s?.siteName ?? '');
    _location   = TextEditingController(text: s?.location ?? '');
    _owner      = TextEditingController(text: s?.ownerName ?? '');
    _ownerPhone = TextEditingController(text: s?.ownerPhone ?? '');
    _budget     = TextEditingController(text: s?.budget.toString() ?? '0');
    _floors     = TextEditingController(text: (s?.floorsCount ?? 1).toString());
    _notes      = TextEditingController(text: s?.notes ?? '');
    _status     = s?.status ?? 'Active';
    if (s?.startDate != null) _startDate = DateTime.tryParse(s!.startDate!);
  }

  @override
  void dispose() {
    for (final c in [_name,_location,_owner,_ownerPhone,_budget,_floors,_notes]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.site == null ? 'Add Site' : 'Edit Site',
          style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            _section('Site Information', Icons.location_city_rounded),
            _field(_name, 'Site Name *', required: true),
            _field(_location, 'Location / Address'),
            Row(children: [
              Expanded(child: _numField(_budget, 'Budget (₹)', required: true)),
              const SizedBox(width: 12),
              Expanded(child: _numField(_floors, 'Number of Floors', required: true)),
            ]),

            const SizedBox(height: 8),
            _section('Owner Details', Icons.person_rounded),
            _field(_owner, 'Owner Name'),
            _field(_ownerPhone, 'Owner Phone', type: TextInputType.phone),

            const SizedBox(height: 8),
            _section('Project Details', Icons.info_outline_rounded),
            // Start Date Picker
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today_rounded, color: cs.primary),
                title: Text(_startDate == null
                  ? 'Select Start Date'
                  : 'Start Date: ${_startDate!.toIso8601String().split('T')[0]}'),
                trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context, firstDate: DateTime(2000), lastDate: DateTime(2100),
                    initialDate: _startDate ?? DateTime.now());
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const ['Active','Completed']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _notes, maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes')),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white),
              child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(widget.site == null ? 'Save Site' : 'Update Site', style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      )),
    );
  }

  Widget _section(String t, IconData icon) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
    child: Row(children: [
      Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _field(TextEditingController c, String label, {TextInputType type = TextInputType.text, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c, keyboardType: type,
        decoration: InputDecoration(labelText: label),
        validator: required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null,
      ),
    );
  }

  Widget _numField(TextEditingController c, String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c, keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) return 'Required';
          if (v != null && v.isNotEmpty && double.tryParse(v) == null) return 'Enter a number';
          return null;
        },
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final site = SiteModel(
        id: widget.site?.id,
        siteName: _name.text.trim(),
        location: _location.text.trim(),
        ownerName: _owner.text.trim(),
        ownerPhone: _ownerPhone.text.trim().isEmpty ? null : _ownerPhone.text.trim(),
        startDate: _startDate?.toIso8601String().split('T')[0],
        budget: double.tryParse(_budget.text.trim()) ?? 0,
        floorsCount: int.tryParse(_floors.text.trim()) ?? 1,
        status: _status,
        notes: _notes.text.trim(),
      );
      if (widget.site == null) await _dao.insertSite(site);
      else await _dao.updateSite(site);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.site == null ? 'Site added!' : 'Site updated!'),
          backgroundColor: Colors.green));
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
