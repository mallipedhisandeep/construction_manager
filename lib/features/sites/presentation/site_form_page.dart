import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _budget     = TextEditingController(text: s != null ? s.budget.toStringAsFixed(0) : '');
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
        constraints: const BoxConstraints(maxWidth: 680),
        child: Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(16), children: [

            // ── SECTION: Site Info ──
            _sectionCard('Site Information', Icons.location_city_rounded, cs, [
              _field(_name, 'Site Name *', required: true),
              _field(_location, 'Location / Address'),
              Row(children: [
                Expanded(child: _numField(_budget, 'Total Budget (₹)')),
                const SizedBox(width: 12),
                Expanded(child: _numField(_floors, 'Number of Floors', isInt: true)),
              ]),
            ]),
            const SizedBox(height: 12),

            // ── SECTION: Owner ──
            _sectionCard('Owner Details', Icons.person_rounded, cs, [
              _field(_owner, 'Owner Name'),
              _field(_ownerPhone, 'Owner Phone',
                type: TextInputType.phone,
                formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
            ]),
            const SizedBox(height: 12),

            // ── SECTION: Project ──
            _sectionCard('Project Details', Icons.info_outline, cs, [
              // Date picker row
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000), lastDate: DateTime(2100),
                    initialDate: _startDate ?? DateTime.now());
                  if (d != null) setState(() => _startDate = d);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade50),
                  child: Row(children: [
                    Icon(Icons.calendar_today_rounded, size: 18, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      _startDate == null
                        ? 'Select Start Date'
                        : 'Start Date: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _startDate == null ? Colors.grey.shade600 : Colors.black87),
                    )),
                    Icon(Icons.edit_calendar_rounded, size: 16, color: Colors.grey.shade400),
                  ]),
                ),
              ),
              const SizedBox(height: 12),

              // Status selector
              Row(children: [
                Text('Status:', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                const SizedBox(width: 12),
                Expanded(child: Row(children: ['Active','Completed'].map((st) {
                  final sel = _status == st;
                  final color = st == 'Active' ? Colors.green : Colors.blue;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _status = st),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? color.withOpacity(0.1) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: sel ? color : Colors.grey.shade300)),
                        child: Text(st, style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: sel ? color : Colors.grey.shade700)),
                      ),
                    ),
                  );
                }).toList())),
              ]),
            ]),
            const SizedBox(height: 12),

            // ── SECTION: Notes ──
            _sectionCard('Notes', Icons.notes_rounded, cs, [
              TextFormField(controller: _notes, maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Any additional notes about this site...',
                  border: OutlineInputBorder())),
            ]),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                  ? const SizedBox(height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_rounded),
                label: Text(widget.site == null ? 'Save Site' : 'Update Site',
                  style: const TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      )),
    );
  }

  Widget _sectionCard(String title, IconData icon, ColorScheme cs, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ]),
          const Divider(height: 16),
          ...children,
        ]),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType type = TextInputType.text, bool required = false,
       List<TextInputFormatter>? formatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        inputFormatters: formatters,
        decoration: InputDecoration(labelText: label),
        validator: required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null,
      ),
    );
  }

  Widget _numField(TextEditingController c, String label, {bool isInt = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [isInt
          ? FilteringTextInputFormatter.digitsOnly
          : FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        decoration: InputDecoration(labelText: label),
        validator: (v) {
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
        startDate: _startDate?.toIso8601String().split('T').first,
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
