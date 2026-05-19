import 'package:flutter/material.dart';

import '../data/site_dao.dart';
import '../data/site_model.dart';

class SiteFormPage
    extends StatefulWidget {

  final SiteModel? site;

  const SiteFormPage({
    super.key,
    this.site,
  });

  @override
  State<SiteFormPage> createState() =>
      _SiteFormPageState();
}

class _SiteFormPageState
    extends State<SiteFormPage> {

  final SiteDao _dao =
      SiteDao();

  final _formKey =
      GlobalKey<FormState>();

  late TextEditingController
      name;

  late TextEditingController
      ownerPhone;

  late TextEditingController
      location;

  late TextEditingController
      owner;

  late TextEditingController
      budget;

  late TextEditingController
      floors;

  late TextEditingController
      notes;

  String status = 'Active';

  DateTime? startDate;

  bool isSaving = false;

  @override
  void initState() {

    super.initState();

    name = TextEditingController(
      text:
          widget.site?.siteName ?? '',
    );

    location =
        TextEditingController(
      text:
          widget.site?.location ?? '',
    );

    owner = TextEditingController(
      text:
          widget.site?.ownerName ?? '',
    );

    ownerPhone =
        TextEditingController(
      text:
          widget.site?.ownerPhone ??
              '',
    );

    budget = TextEditingController(
      text:
          widget.site?.budget
              .toString() ??
              '',
    );

    floors = TextEditingController(
      text:
          (widget.site?.floorsCount ??
                  1)
              .toString(),
    );

    notes = TextEditingController(
      text:
          widget.site?.notes ?? '',
    );

    status =
        widget.site?.status ??
            'Active';

    if (widget.site?.startDate !=
        null) {

      startDate = DateTime.parse(
        widget.site!.startDate!,
      );
    }
  }

  // ==============================
  // UI
  // ==============================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(

          widget.site == null
              ? 'Add Site'
              : 'Edit Site',
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Form(

          key: _formKey,

          child: ListView(

            children: [

              _field(
                name,
                'Site Name',
                true,
              ),

              _field(
                location,
                'Location',
              ),

              _field(
                owner,
                'Owner Name',
              ),

              _field(
                ownerPhone,
                'Owner Contact Number',
                false,
                TextInputType.phone,
              ),

              const SizedBox(
                height: 8,
              ),

              _datePicker(),

              _field(
                budget,
                'Budget',
                true,
                TextInputType.number,
              ),

              _field(
                floors,
                'Floors',
                true,
                TextInputType.number,
              ),

              const SizedBox(
                height: 12,
              ),

              DropdownButtonFormField<
                  String>(

                value: status,

                decoration:
                    const InputDecoration(
                  labelText: 'Status',
                ),

                items: const [

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

                  setState(() {
                    status = v!;
                  });
                },
              ),

              const SizedBox(
                height: 20,
              ),

              ElevatedButton(

                onPressed:
                    isSaving
                        ? null
                        : _save,

                child: isSaving

                    ? const SizedBox(

                        height: 18,
                        width: 18,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )

                    : const Text(
                        'Save',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================
  // DATE PICKER
  // ==============================

  Widget _datePicker() {

    return ListTile(

      contentPadding:
          EdgeInsets.zero,

      title: Text(

        startDate == null

            ? 'Start Date'

            : 'Start Date: '
                '${startDate!.toIso8601String().split('T')[0]}',
      ),

      trailing:
          const Icon(
        Icons.calendar_today,
      ),

      onTap: () async {

        final picked =
            await showDatePicker(

          context: context,

          firstDate:
              DateTime(2000),

          lastDate:
              DateTime(2100),

          initialDate:
              startDate ??
                  DateTime.now(),
        );

        if (picked != null) {

          setState(() {
            startDate = picked;
          });
        }
      },
    );
  }

  // ==============================
  // FIELD
  // ==============================

  Widget _field(

    TextEditingController c,

    String label, [

    bool req = false,

    TextInputType type =
        TextInputType.text,

  ]) {

    return TextFormField(

      controller: c,

      keyboardType: type,

      decoration: InputDecoration(
        labelText: label,
      ),

      validator: (v) {

        if (req &&
            (v == null ||
                v.trim().isEmpty)) {

          return 'Required';
        }

        if (type ==
            TextInputType.number) {

          final n =
              double.tryParse(
            v!.trim(),
          );

          if (n == null) {
            return 'Enter valid number';
          }
        }

        return null;
      },
    );
  }

  // ==============================
  // SAVE
  // ==============================

  Future<void> _save() async {

    if (!_formKey.currentState!
        .validate()) {

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {

      final site = SiteModel(

        id:
            widget.site?.id,

        siteName:
            name.text.trim(),

        location:
            location.text.trim(),

        ownerName:
            owner.text.trim(),

        ownerPhone:
            ownerPhone.text.trim()
                    .isEmpty
                ? null
                : ownerPhone.text.trim(),

        startDate:
            startDate == null

                ? null

                : startDate!
                    .toIso8601String()
                    .split('T')[0],

        budget:
            double.parse(
          budget.text.trim(),
        ),

        floorsCount:
            int.parse(
          floors.text.trim(),
        ),

        status: status,

        notes:
            notes.text.trim(),
      );

      if (widget.site == null) {

        await _dao.insertSite(
          site,
        );

      } else {

        await _dao.updateSite(
          site,
        );
      }

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );

    } catch (e) {

      debugPrint(
        'SAVE SITE ERROR => $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          isSaving = false;
        });
      }
    }
  }
}