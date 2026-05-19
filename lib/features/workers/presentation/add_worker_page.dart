import 'package:flutter/material.dart';

import '../data/worker_dao.dart';
import '../data/worker_model.dart';

class AddWorkerPage extends StatefulWidget {
  final WorkerModel? worker;

  const AddWorkerPage({
    super.key,
    this.worker,
  });

  @override
  State<AddWorkerPage> createState() =>
      _AddWorkerPageState();
}

class _AddWorkerPageState
    extends State<AddWorkerPage> {

  final _formKey = GlobalKey<FormState>();

  final WorkerDao _dao = WorkerDao();

  // ==============================
  // CONTROLLERS
  // ==============================

  final TextEditingController
      nameController =
      TextEditingController();

  final TextEditingController
      phoneController =
      TextEditingController();

  final TextEditingController
      rate6to6Controller =
      TextEditingController();

  final TextEditingController
      rate10to6Controller =
      TextEditingController();

  final TextEditingController
      rate6to10Controller =
      TextEditingController();

  final TextEditingController
      rate6to2Controller =
      TextEditingController();

  final TextEditingController
      rate10to2Controller =
      TextEditingController();

  final TextEditingController
      rate2to6Controller =
      TextEditingController();

  final TextEditingController
      notesController =
      TextEditingController();

  // ==============================
  // DROPDOWN VALUES
  // ==============================

  String selectedGender = 'Male';

  String selectedState =
      'Telangana';

  String selectedRole =
      'Mason';

  String selectedWorkType =
      'Centring';

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    // ==========================
    // EDIT MODE
    // ==========================

    if (widget.worker != null) {

      nameController.text =
          widget.worker!.name;

      phoneController.text =
          widget.worker!.phone;

      selectedGender =
          widget.worker!.gender;

      selectedState =
          widget.worker!.state;

      selectedRole =
          widget.worker!.role;

      selectedWorkType =
          widget.worker!.workType;

      rate6to6Controller.text =
          widget.worker!.rate6to6
              .toString();

      rate10to6Controller.text =
          widget.worker!.rate10to6
              .toString();

      rate6to10Controller.text =
          widget.worker!.rate6to10
              .toString();

      rate6to2Controller.text =
          widget.worker!.rate6to2
              .toString();

      rate10to2Controller.text =
          widget.worker!.rate10to2
              .toString();

      rate2to6Controller.text =
          widget.worker!.rate2to6
              .toString();

      notesController.text =
          widget.worker!.notes ?? '';
    }
  }

  // ==============================
  // SAVE WORKER
  // ==============================

  Future<void> saveWorker() async {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {

      final worker = WorkerModel(
        id: widget.worker?.id,

        name:
            nameController.text.trim(),

        phone:
            phoneController.text.trim(),

        gender: selectedGender,

        state: selectedState,

        role: selectedRole,

        workType:
            selectedWorkType,

        rate6to6:
            double.tryParse(
                  rate6to6Controller
                      .text,
                ) ??
                0,

        rate10to6:
            double.tryParse(
                  rate10to6Controller
                      .text,
                ) ??
                0,

        rate6to10:
            double.tryParse(
                  rate6to10Controller
                      .text,
                ) ??
                0,

        rate6to2:
            double.tryParse(
                  rate6to2Controller
                      .text,
                ) ??
                0,

        rate10to2:
            double.tryParse(
                  rate10to2Controller
                      .text,
                ) ??
                0,

        rate2to6:
            double.tryParse(
                  rate2to6Controller
                      .text,
                ) ??
                0,

        notes:
            notesController.text
                .trim(),
      );

      // ==========================
      // INSERT OR UPDATE
      // ==========================

      if (widget.worker == null) {

        await _dao.insertWorker(
          worker,
        );

      } else {

        await _dao.updateWorker(
          worker,
        );
      }

      if (mounted) {

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              widget.worker == null
                  ? 'Worker added successfully'
                  : 'Worker updated successfully',
            ),
          ),
        );

        Navigator.pop(
          context,
          true,
        );
      }

    } catch (e) {

      debugPrint(
        'Save worker error: $e',
      );

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.worker == null
              ? 'Add Worker'
              : 'Edit Worker',
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [

              // ==================
              // NAME
              // ==================

              TextFormField(
                controller:
                    nameController,

                decoration:
                    const InputDecoration(
                  labelText: 'Name',
                ),

                validator: (v) {

                  if (v == null ||
                      v.trim().isEmpty) {
                    return 'Required';
                  }

                  return null;
                },
              ),

              // ==================
              // PHONE
              // ==================

              TextFormField(
                controller:
                    phoneController,

                keyboardType:
                    TextInputType.phone,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Mobile Number',
                ),

                validator: (v) {

                  if (v == null ||
                      v.length < 10) {
                    return 'Invalid number';
                  }

                  return null;
                },
              ),

              // ==================
              // DROPDOWNS
              // ==================

              dropdown(
                'Gender',
                selectedGender,
                [
                  'Male',
                  'Female',
                ],
                (v) {
                  setState(() {
                    selectedGender =
                        v;
                  });
                },
              ),

              dropdown(
                'Work Type',
                selectedWorkType,
                [
                  'Centring',
                  'Brickwork',
                ],
                (v) {
                  setState(() {
                    selectedWorkType =
                        v;
                  });
                },
              ),

              dropdown(
                'State',
                selectedState,
                [
                  'Telangana',
                  'Andhra',
                  'Bihar',
                ],
                (v) {
                  setState(() {
                    selectedState =
                        v;
                  });
                },
              ),

              dropdown(
                'Role',
                selectedRole,
                [
                  'Mason',
                  'Helper',
                ],
                (v) {
                  setState(() {
                    selectedRole = v;
                  });
                },
              ),

              const SizedBox(
                height: 16,
              ),

              const Text(
                'Wages',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              wageField(
                rate6to6Controller,
                '6 AM – 6 PM',
              ),

              wageField(
                rate10to6Controller,
                '10 AM – 6 PM',
              ),

              wageField(
                rate6to10Controller,
                '6 AM – 10 AM',
              ),

              wageField(
                rate6to2Controller,
                '6 AM – 2 PM',
              ),

              wageField(
                rate10to2Controller,
                '10 AM – 2 PM',
              ),

              wageField(
                rate2to6Controller,
                '2 PM – 6 PM',
              ),

              // ==================
              // NOTES
              // ==================

              TextFormField(
                controller:
                    notesController,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Notes (optional)',
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================
              // SAVE BUTTON
              // ==================

              ElevatedButton(
                onPressed:
                    isSaving
                        ? null
                        : saveWorker,

                child: isSaving
                    ? const CircularProgressIndicator()
                    : Text(
                        widget.worker ==
                                null
                            ? 'Save Worker'
                            : 'Update Worker',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================
  // DROPDOWN WIDGET
  // ==============================

  Widget dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String>
        onChanged,
  ) {

    return DropdownButtonFormField<
        String>(
      value: value,

      decoration:
          InputDecoration(
        labelText: label,
      ),

      items: items
          .map(
            (e) =>
                DropdownMenuItem(
              value: e,
              child: Text(e),
            ),
          )
          .toList(),

      onChanged: (v) {
        if (v != null) {
          onChanged(v);
        }
      },
    );
  }

  // ==============================
  // WAGE FIELD
  // ==============================

  Widget wageField(
    TextEditingController
        controller,
    String label,
  ) {

    return TextFormField(
      controller: controller,

      keyboardType:
          TextInputType.number,

      decoration:
          InputDecoration(
        labelText: label,
        prefixText: '₹ ',
      ),
    );
  }
}