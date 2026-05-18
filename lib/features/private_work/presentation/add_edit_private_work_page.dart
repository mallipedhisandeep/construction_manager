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
  State<AddEditPrivateWorkPage> createState() =>
      _AddEditPrivateWorkPageState();
}

class _AddEditPrivateWorkPageState extends State<AddEditPrivateWorkPage> {
  final _dao = PrivateWorkDao();
  final _workerDao = PrivateWorkerDao();
  final _siteDao = SiteDao();
  final _form = GlobalKey<FormState>();

  List<PrivateWorker> workers = [];
  List<SiteModel> sites = [];

  PrivateWorker? worker;
  SiteModel? site;

  late TextEditingController price, paid, notes;
  String status = 'Active';
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
    price = TextEditingController(
        text: widget.work?.priceCharged.toString() ?? '');
    paid = TextEditingController(
        text: widget.work?.amountPaid.toString() ?? '');
    notes = TextEditingController(text: widget.work?.notes ?? '');
    status = widget.work?.status ?? 'Active';
    load();
  }

  Future<void> load() async {
    workers = await _workerDao.getAll();
    sites = await _siteDao.getAllSites();

    if (widget.work != null) {
      worker = workers.firstWhere((e) => e.id == widget.work!.workerId);
      site = sites.firstWhere((e) => e.siteName == widget.work!.siteName);
      date = DateTime.parse(widget.work!.workDate);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text(widget.work == null ? 'Add Work' : 'Edit Work')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              DropdownButtonFormField<PrivateWorker>(
                value: worker,
                items: workers
                    .map((w) =>
                    DropdownMenuItem(value: w, child: Text(w.name)))
                    .toList(),
                onChanged: (v) => setState(() => worker = v),
                validator: (v) => v == null ? 'Required' : null,
                decoration: const InputDecoration(labelText: 'Worker'),
              ),
              if (worker != null) Text('Work Type: ${worker!.workType}'),

              DropdownButtonFormField<SiteModel>(
                value: site,
                items: sites
                    .map((s) =>
                    DropdownMenuItem(value: s, child: Text(s.siteName)))
                    .toList(),
                onChanged: (v) => setState(() => site = v),
                validator: (v) => v == null ? 'Required' : null,
                decoration: const InputDecoration(labelText: 'Site'),
              ),

              ListTile(
                title: Text(
                    'Date: ${date.toIso8601String().split('T')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDate: date,
                  );
                  if (d != null) setState(() => date = d);
                },
              ),

              TextFormField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: 'Price Charged'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              TextFormField(
                controller: paid,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: 'Amount Paid by Dad'),
              ),

              DropdownButtonFormField(
                value: status,
                items: const ['Active', 'Completed']
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => status = v!,
              ),

              const SizedBox(height: 20),
              ElevatedButton(onPressed: save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> save() async {
    if (!_form.currentState!.validate()) return;
    if (worker == null || site == null) return;

    final work = PrivateWork(
      id: widget.work?.id,
      workerId: worker!.id!,
      workerName: worker!.name,
      workType: worker!.workType,
      siteName: site!.siteName,
      workDate: date.toIso8601String().split('T')[0],
      priceCharged: double.parse(price.text),
      amountPaid: paid.text.isEmpty ? 0 : double.parse(paid.text),
      status: status,
      notes: notes.text,
    );

    if (widget.work == null) {
      await _dao.insert(work);
    } else {
      await _dao.update(work);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }
}