import 'package:flutter/material.dart';
import '../data/private_worker_dao.dart';
import '../data/private_worker_model.dart';

class AddEditPrivateWorkerPage extends StatefulWidget {
  final PrivateWorker? worker;
  const AddEditPrivateWorkerPage({super.key, this.worker});

  @override
  State<AddEditPrivateWorkerPage> createState() =>
      _AddEditPrivateWorkerPageState();
}

class _AddEditPrivateWorkerPageState extends State<AddEditPrivateWorkerPage> {
  final _dao = PrivateWorkerDao();
  final _form = GlobalKey<FormState>();

  late TextEditingController name, work, phone, notes;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.worker?.name ?? '');
    work = TextEditingController(text: widget.worker?.workType ?? '');
    phone = TextEditingController(text: widget.worker?.phone ?? '');
    notes = TextEditingController(text: widget.worker?.notes ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text(widget.worker == null ? 'Add' : 'Edit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              _f(name, 'Name', true),
              _f(work, 'Work Type', true),
              _f(phone, 'Phone', true),
              _f(notes, 'Notes'),
              ElevatedButton(onPressed: save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _f(TextEditingController c, String l, [bool r = false]) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(labelText: l),
      validator: r ? (v) => v!.isEmpty ? 'Required' : null : null,
    );
  }

  Future<void> save() async {
    if (!_form.currentState!.validate()) return;

    final w = PrivateWorker(
      id: widget.worker?.id,
      name: name.text,
      workType: work.text,
      phone: phone.text,
      notes: notes.text,
    );

    widget.worker == null ? await _dao.insert(w) : await _dao.update(w);
    Navigator.pop(context, true);
  }
}