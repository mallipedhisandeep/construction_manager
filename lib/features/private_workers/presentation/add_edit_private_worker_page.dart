import 'package:flutter/material.dart';
import '../data/private_worker_dao.dart';
import '../data/private_worker_model.dart';

class AddEditPrivateWorkerPage extends StatefulWidget {
  final PrivateWorker? worker;
  const AddEditPrivateWorkerPage({super.key, this.worker});
  @override
  State<AddEditPrivateWorkerPage> createState() => _AddEditPrivateWorkerPageState();
}

class _AddEditPrivateWorkerPageState extends State<AddEditPrivateWorkerPage> {
  final _formKey = GlobalKey<FormState>();
  final _dao = PrivateWorkerDao();
  late TextEditingController _name, _work, _phone, _notes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name  = TextEditingController(text: widget.worker?.name ?? '');
    _work  = TextEditingController(text: widget.worker?.workType ?? '');
    _phone = TextEditingController(text: widget.worker?.phone ?? '');
    _notes = TextEditingController(text: widget.worker?.notes ?? '');
  }

  @override
  void dispose() { _name.dispose(); _work.dispose(); _phone.dispose(); _notes.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.worker == null ? 'Add Contractor' : 'Edit Contractor',
          style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            _field(_name, 'Name *', required: true),
            _field(_work, 'Work Type *', required: true, hint: 'e.g. Centring, Brickwork, Plumbing'),
            _field(_phone, 'Phone Number *', required: true, type: TextInputType.phone),
            _field(_notes, 'Notes', maxLines: 3),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white),
              child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(widget.worker == null ? 'Save Contractor' : 'Update Contractor',
                    style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      )),
    );
  }

  Widget _field(TextEditingController c, String label,
      {bool required = false, TextInputType type = TextInputType.text, String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c, keyboardType: type, maxLines: maxLines,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final w = PrivateWorker(
        id: widget.worker?.id, name: _name.text.trim(),
        workType: _work.text.trim(), phone: _phone.text.trim(),
        notes: _notes.text.trim(), createdAt: widget.worker?.createdAt ?? DateTime.now());
      if (widget.worker == null) await _dao.insert(w);
      else await _dao.update(w);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.worker == null ? 'Contractor added!' : 'Contractor updated!'),
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
