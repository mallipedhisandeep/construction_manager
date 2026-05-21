import 'package:flutter/material.dart';
import '../data/worker_dao.dart';
import '../data/worker_model.dart';

class AddWorkerPage extends StatefulWidget {
  final WorkerModel? worker;
  const AddWorkerPage({super.key, this.worker});
  @override
  State<AddWorkerPage> createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  final _formKey = GlobalKey<FormState>();
  final WorkerDao _dao = WorkerDao();

  late final TextEditingController _name, _phone, _r66, _r106, _r610, _r62, _r102, _r26, _notes;

  String _gender = 'Male';
  String _state = 'Telangana';
  String _role = 'Mason';
  String _workType = 'Centring';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final w = widget.worker;
    _name   = TextEditingController(text: w?.name ?? '');
    _phone  = TextEditingController(text: w?.phone ?? '');
    _r66    = TextEditingController(text: w?.rate6to6.toString() ?? '0');
    _r106   = TextEditingController(text: w?.rate10to6.toString() ?? '0');
    _r610   = TextEditingController(text: w?.rate6to10.toString() ?? '0');
    _r62    = TextEditingController(text: w?.rate6to2.toString() ?? '0');
    _r102   = TextEditingController(text: w?.rate10to2.toString() ?? '0');
    _r26    = TextEditingController(text: w?.rate2to6.toString() ?? '0');
    _notes  = TextEditingController(text: w?.notes ?? '');
    if (w != null) { _gender = w.gender; _state = w.state; _role = w.role; _workType = w.workType; }
  }

  @override
  void dispose() {
    for (final c in [_name,_phone,_r66,_r106,_r610,_r62,_r102,_r26,_notes]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.worker == null ? 'Add Worker' : 'Edit Worker',
          style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section('Personal Info', Icons.person_outline),
              _field(_name, 'Full Name', required: true),
              _field(_phone, 'Mobile Number', type: TextInputType.phone,
                validator: (v) => v != null && v.trim().length >= 10 ? null : 'Enter valid 10-digit number'),
              Row(children: [
                Expanded(child: _dropdown('Gender', _gender, ['Male','Female'], (v) => setState(() => _gender = v))),
                const SizedBox(width: 12),
                Expanded(child: _dropdown('Work Type', _workType, ['Centring','Brickwork'], (v) => setState(() => _workType = v))),
              ]),
              Row(children: [
                Expanded(child: _dropdown('State', _state, ['Telangana','Andhra','Bihar'], (v) => setState(() => _state = v))),
                const SizedBox(width: 12),
                Expanded(child: _dropdown('Role', _role, ['Mason','Helper'], (v) => setState(() => _role = v))),
              ]),

              const SizedBox(height: 8),
              _section('Wage Rates (₹)', Icons.currency_rupee),
              _wageRow('6 AM – 6 PM', _r66),
              _wageRow('10 AM – 6 PM', _r106),
              _wageRow('6 AM – 10 PM', _r610),
              _wageRow('6 AM – 2 PM', _r62),
              _wageRow('10 AM – 2 PM', _r102),
              _wageRow('2 PM – 6 PM', _r26),

              const SizedBox(height: 8),
              _section('Notes', Icons.notes),
              TextFormField(controller: _notes, maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes (optional)')),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white),
                child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(widget.worker == null ? 'Save Worker' : 'Update Worker', style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      )),
    );
  }

  Widget _section(String title, IconData icon) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
    child: Row(children: [
      Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _field(TextEditingController c, String label, {TextInputType type = TextInputType.text, bool required = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c, keyboardType: type,
        decoration: InputDecoration(labelText: label),
        validator: validator ?? (required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }

  Widget _wageRow(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 14))),
        const SizedBox(width: 12),
        Expanded(flex: 1, child: TextFormField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '₹ ', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
        )),
      ]),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final w = WorkerModel(
        id: widget.worker?.id,
        name: _name.text.trim(), phone: _phone.text.trim(),
        gender: _gender, state: _state, role: _role, workType: _workType,
        rate6to6: double.tryParse(_r66.text) ?? 0,
        rate10to6: double.tryParse(_r106.text) ?? 0,
        rate6to10: double.tryParse(_r610.text) ?? 0,
        rate6to2: double.tryParse(_r62.text) ?? 0,
        rate10to2: double.tryParse(_r102.text) ?? 0,
        rate2to6: double.tryParse(_r26.text) ?? 0,
        notes: _notes.text.trim(),
      );
      if (widget.worker == null) {
        await _dao.insertWorker(w);
      } else {
        await _dao.updateWorker(w);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.worker == null ? 'Worker added!' : 'Worker updated!'),
          backgroundColor: Colors.green,
        ));
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
