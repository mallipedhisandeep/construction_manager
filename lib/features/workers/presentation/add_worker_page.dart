import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../data/worker_dao.dart';
import '../data/worker_model.dart';

class AddWorkerPage extends ConsumerStatefulWidget {
  final WorkerModel? worker;
  const AddWorkerPage({super.key, this.worker});
  @override
  ConsumerState<AddWorkerPage> createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends ConsumerState<AddWorkerPage> {
  final _formKey = GlobalKey<FormState>();
  final WorkerDao _dao = WorkerDao();

  late final TextEditingController _name, _phone, _r66, _r106, _r610, _r62, _r102, _r26, _notes;
  String _gender = 'Male', _state = 'Telangana', _role = 'Mason', _workType = 'Centring';
  bool _saving = false;

  // Input formatter that allows numbers + single decimal point
  static final _numFmt = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'));
  static final _digitOnly = FilteringTextInputFormatter.digitsOnly;

  @override
  void initState() {
    super.initState();
    final w = widget.worker;
    _name  = TextEditingController(text: w?.name ?? '');
    _phone = TextEditingController(text: w?.phone ?? '');
    _r66   = TextEditingController(text: w?.rate6to6.toStringAsFixed(0) ?? '0');
    _r106  = TextEditingController(text: w?.rate10to6.toStringAsFixed(0) ?? '0');
    _r610  = TextEditingController(text: w?.rate6to10.toStringAsFixed(0) ?? '0');
    _r62   = TextEditingController(text: w?.rate6to2.toStringAsFixed(0) ?? '0');
    _r102  = TextEditingController(text: w?.rate10to2.toStringAsFixed(0) ?? '0');
    _r26   = TextEditingController(text: w?.rate2to6.toStringAsFixed(0) ?? '0');
    _notes = TextEditingController(text: w?.notes ?? '');
    if (w != null) { _gender = w.gender; _state = w.state; _role = w.role; _workType = w.workType; }
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _r66, _r106, _r610, _r62, _r102, _r26, _notes]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(ref.watch(languageProvider));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.worker == null ? s.addWorker : s.editWorker,
          style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
      ),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(16), children: [

            _sectionHeader(s.personalInfo, Icons.person_outline, cs),

            // Name
            Padding(padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: s.name),
                validator: (v) => v == null || v.trim().isEmpty ? s.required : null,
              )),

            // Phone — digits only, max 10
            Padding(padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [_digitOnly, LengthLimitingTextInputFormatter(10)],
                decoration: InputDecoration(
                  labelText: s.mobileNumber,
                  counterText: '${_phone.text.length}/10',
                ),
                onChanged: (_) => setState(() {}), // update counter
                validator: (v) => v == null || v.trim().length != 10 ? s.invalidPhone : null,
              )),

            Row(children: [
              Expanded(child: _dropdown(s.gender, _gender, ['Male', 'Female'],
                [s.male, s.female], (v) => setState(() => _gender = v))),
              const SizedBox(width: 12),
              Expanded(child: _dropdown(s.workType, _workType, ['Centring', 'Brickwork'],
                [s.centring, s.brickwork], (v) => setState(() => _workType = v))),
            ]),
            Row(children: [
              Expanded(child: _dropdown(s.state, _state, ['Telangana', 'Andhra', 'Bihar'],
                ['Telangana', 'Andhra', 'Bihar'], (v) => setState(() => _state = v))),
              const SizedBox(width: 12),
              Expanded(child: _dropdown(s.role, _role, ['Mason', 'Helper'],
                [s.mason, s.helper], (v) => setState(() => _role = v))),
            ]),

            const SizedBox(height: 8),
            _sectionHeader(s.wageRates, Icons.currency_rupee, cs),

            // Wage fields — numbers only
            _wageRow(S(false).r66,  _r66),
            _wageRow(S(false).r106, _r106),
            _wageRow(S(false).r610, _r610),
            _wageRow(S(false).r62,  _r62),
            _wageRow(S(false).r102, _r102),
            _wageRow(S(false).r26,  _r26),

            const SizedBox(height: 8),
            _sectionHeader(s.notes, Icons.notes, cs),
            TextFormField(controller: _notes, maxLines: 3,
              decoration: InputDecoration(labelText: s.notes)),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white),
              child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(widget.worker == null ? s.saveWorker : s.updateWorker,
                    style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      )),
    );
  }

  Widget _sectionHeader(String title, IconData icon, ColorScheme cs) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
    child: Row(children: [
      Icon(icon, size: 18, color: cs.primary),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _dropdown(String label, String value, List<String> values, List<String> labels, ValueChanged<String> onChange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: List.generate(values.length, (i) =>
          DropdownMenuItem(value: values[i], child: Text(labels[i]))),
        onChanged: (v) { if (v != null) onChange(v); },
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
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // ONLY digits, no letters
          ],
          decoration: const InputDecoration(
            prefixText: '₹ ',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
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
        rate6to6:  double.tryParse(_r66.text)  ?? 0,
        rate10to6: double.tryParse(_r106.text) ?? 0,
        rate6to10: double.tryParse(_r610.text) ?? 0,
        rate6to2:  double.tryParse(_r62.text)  ?? 0,
        rate10to2: double.tryParse(_r102.text) ?? 0,
        rate2to6:  double.tryParse(_r26.text)  ?? 0,
        notes: _notes.text.trim(),
      );
      if (widget.worker == null) await _dao.insertWorker(w);
      else await _dao.updateWorker(w);
      if (mounted) {
        final s = S(ref.read(languageProvider));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.worker == null ? s.workerAdded : s.workerUpdated),
          backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        final s = S(ref.read(languageProvider));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${s.errorPrefix}$e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
