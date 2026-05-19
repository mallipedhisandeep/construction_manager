import 'package:flutter/material.dart';

import '../data/private_work_dao.dart';
import '../data/private_work_model.dart';

import '../../private_workers/data/private_worker_dao.dart';
import '../../private_workers/data/private_worker_model.dart';

import '../../sites/data/site_dao.dart';
import '../../sites/data/site_model.dart';

class AddEditPrivateWorkPage
    extends StatefulWidget {
  final PrivateWork? work;

  const AddEditPrivateWorkPage({
    super.key,
    this.work,
  });

  @override
  State<AddEditPrivateWorkPage>
      createState() =>
          _AddEditPrivateWorkPageState();
}

class _AddEditPrivateWorkPageState
    extends State<
        AddEditPrivateWorkPage> {
  final _dao = PrivateWorkDao();

  final _workerDao =
      PrivateWorkerDao();

  final _siteDao = SiteDao();

  final _form =
      GlobalKey<FormState>();

  List<PrivateWorker> workers =
      [];

  List<SiteModel> sites = [];

  PrivateWorker? worker;

  SiteModel? site;

  late TextEditingController
      price;

  late TextEditingController
      paid;

  late TextEditingController
      notes;

  String status = 'Active';

  DateTime date = DateTime.now();

  bool loading = true;

  @override
  void initState() {
    super.initState();

    price = TextEditingController(
      text: widget.work
              ?.priceCharged
              .toString() ??
          '',
    );

    paid = TextEditingController(
      text: widget
              .work?.amountPaid
              .toString() ??
          '',
    );

    notes = TextEditingController(
      text: widget.work?.notes ?? '',
    );

    status =
        widget.work?.status ??
            'Active';

    load();
  }

  @override
  void dispose() {
    price.dispose();
    paid.dispose();
    notes.dispose();

    super.dispose();
  }

  Future<void> load() async {
    workers =
        await _workerDao.getAll();

    sites =
        await _siteDao.getAllSites();

    if (widget.work != null) {
      worker = workers.firstWhere(
        (e) =>
            e.id ==
            widget.work!.workerId,
      );

      site = sites.firstWhere(
        (e) =>
            e.id ==
            widget.work!.siteId,
      );

      date = DateTime.parse(
        widget.work!.workDate,
      );
    }

    loading = false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.work == null
              ? 'Add Private Work'
              : 'Edit Private Work',
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              DropdownButtonFormField<
                  PrivateWorker>(
                value: worker,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Worker',
                ),
                items: workers
                    .map(
                      (w) =>
                          DropdownMenuItem(
                        value: w,
                        child: Text(
                          w.name,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    worker = v;
                  });
                },
                validator: (v) =>
                    v == null
                        ? 'Required'
                        : null,
              ),

              const SizedBox(height: 12),

              if (worker != null)
                Text(
                  'Work Type: ${worker!.workType}',
                ),

              const SizedBox(height: 12),

              DropdownButtonFormField<
                  SiteModel>(
                value: site,
                decoration:
                    const InputDecoration(
                  labelText: 'Site',
                ),
                items: sites
                    .map(
                      (s) =>
                          DropdownMenuItem(
                        value: s,
                        child: Text(
                          s.siteName,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    site = v;
                  });
                },
                validator: (v) =>
                    v == null
                        ? 'Required'
                        : null,
              ),

              const SizedBox(height: 12),

              ListTile(
                contentPadding:
                    EdgeInsets.zero,
                title: Text(
                  'Date: ${date.toIso8601String().split('T')[0]}',
                ),
                trailing: const Icon(
                  Icons.calendar_today,
                ),
                onTap: () async {
                  final d =
                      await showDatePicker(
                    context: context,
                    firstDate:
                        DateTime(2000),
                    lastDate:
                        DateTime(2100),
                    initialDate: date,
                  );

                  if (d != null) {
                    setState(() {
                      date = d;
                    });
                  }
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: price,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Price Charged',
                ),
                validator: (v) {
                  if (v == null ||
                      v.isEmpty) {
                    return 'Required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: paid,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Amount Paid',
                ),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField(
                value: status,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Status',
                ),
                items:
                    const [
                      'Active',
                      'Completed',
                    ]
                        .map(
                          (e) =>
                              DropdownMenuItem(
                            value: e,
                            child:
                                Text(e),
                          ),
                        )
                        .toList(),
                onChanged: (v) {
                  status = v!;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: notes,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Notes',
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: save,
                child: Text(
                  widget.work == null
                      ? 'Save Work'
                      : 'Update Work',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> save() async {
    if (!_form.currentState!
        .validate()) {
      return;
    }

    if (worker == null ||
        site == null) {
      return;
    }

    final work = PrivateWork(
      id: widget.work?.id,
      workerId: worker!.id!,
      workerName: worker!.name,
      workType: worker!.workType,
      siteId: site!.id!,
      siteName: site!.siteName,
      workDate: date
          .toIso8601String()
          .split('T')
          .first,
      priceCharged:
          double.parse(
        price.text.trim(),
      ),
      amountPaid:
          paid.text.trim().isEmpty
              ? 0
              : double.parse(
                  paid.text.trim(),
                ),
      status: status,
      notes: notes.text.trim(),
      createdAt:
          widget.work?.createdAt ??
              DateTime.now(),
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