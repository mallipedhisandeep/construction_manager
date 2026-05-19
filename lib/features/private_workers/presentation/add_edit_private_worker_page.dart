import 'package:flutter/material.dart';

import '../data/private_worker_dao.dart';
import '../data/private_worker_model.dart';

class AddEditPrivateWorkerPage extends StatefulWidget {
  final PrivateWorker? worker;

  const AddEditPrivateWorkerPage({
    super.key,
    this.worker,
  });

  @override
  State<AddEditPrivateWorkerPage> createState() =>
      _AddEditPrivateWorkerPageState();
}

class _AddEditPrivateWorkerPageState
    extends State<AddEditPrivateWorkerPage> {
  final _dao = PrivateWorkerDao();

  final _form = GlobalKey<FormState>();

  late TextEditingController name;
  late TextEditingController work;
  late TextEditingController phone;
  late TextEditingController notes;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(
      text: widget.worker?.name ?? '',
    );

    work = TextEditingController(
      text: widget.worker?.workType ?? '',
    );

    phone = TextEditingController(
      text: widget.worker?.phone ?? '',
    );

    notes = TextEditingController(
      text: widget.worker?.notes ?? '',
    );
  }

  @override
  void dispose() {
    name.dispose();
    work.dispose();
    phone.dispose();
    notes.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.worker != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? 'Edit Private Worker'
              : 'Add Private Worker',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              _field(name, 'Name', true),

              const SizedBox(height: 12),

              _field(work, 'Work Type', true),

              const SizedBox(height: 12),

              _field(
                phone,
                'Phone Number',
                true,
                TextInputType.phone,
              ),

              const SizedBox(height: 12),

              _field(notes, 'Notes'),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: save,
                child: Text(
                  isEdit
                      ? 'Update Worker'
                      : 'Save Worker',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, [
    bool required = false,
    TextInputType keyboard =
        TextInputType.text,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (v) {
              if (v == null ||
                  v.trim().isEmpty) {
                return 'Required';
              }

              return null;
            }
          : null,
    );
  }

  Future<void> save() async {
    if (!_form.currentState!.validate()) {
      return;
    }

    final worker = PrivateWorker(
      id: widget.worker?.id,
      name: name.text.trim(),
      workType: work.text.trim(),
      phone: phone.text.trim(),
      notes: notes.text.trim(),
      createdAt:
          widget.worker?.createdAt ??
              DateTime.now(),
    );

    if (widget.worker == null) {
      await _dao.insert(worker);
    } else {
      await _dao.update(worker);
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }
}