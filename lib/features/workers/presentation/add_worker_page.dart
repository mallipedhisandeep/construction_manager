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

  final _formKey =
      GlobalKey<FormState>();

  final WorkerDao _dao =
      WorkerDao();

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

  String selectedGender =
      'Male';

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

    final worker =
        widget.worker;

    if (worker != null) {

      nameController.text =
          worker.name;

      phoneController.text =
          worker.phone;

      selectedGender =
          worker.gender;

      selectedState =
          worker.state;

      selectedRole =
          worker.role;

      selectedWorkType =
          worker.workType;

      rate6to6Controller.text =
          worker.rate6to6
              .toString();

      rate10to6Controller.text =
          worker.rate10to6
              .toString();

      rate6to10Controller.text =
          worker.rate6to10
              .toString();

      rate6to2Controller.text =
          worker.rate6to2
              .toString();

      rate10to2Controller.text =
          worker.rate10to2
              .toString();

      rate2to6Controller.text =
          worker.rate2to6
              .toString();

      notesController.text =
          worker.notes ?? '';
    }
  }

  @override
  void dispose() {

    nameController.dispose();

    phoneController.dispose();

    rate6to6Controller.dispose();

    rate10to6Controller.dispose();

    rate6to10Controller.dispose();

    rate6to2Controller.dispose();

    rate10to2Controller.dispose();

    rate2to6Controller.dispose();

    notesController.dispose();

    super.dispose();
  }

  Future<void> saveWorker() async {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {

      final worker =
          WorkerModel(

        id:
            widget.worker?.id,

        name:
            nameController.text
                .trim(),

        phone:
            phoneController.text
                .trim(),

        gender:
            selectedGender,

        state:
            selectedState,

        role:
            selectedRole,

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

      if (widget.worker == null) {

        await _dao.insertWorker(
          worker,
        );

      } else {

        await _dao.updateWorker(
          worker,
        );
      }

      if (!mounted) {
        return;
      }

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

    } catch (e) {

      debugPrint(
        'SAVE WORKER ERROR => $e',
      );

      if (!mounted) {
        return;
      }

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

      body: Center(

        child: ConstrainedBox(

          constraints:
              const BoxConstraints(
            maxWidth: 700,
          ),

          child: Padding(

            padding:
                const EdgeInsets.all(
              16,
            ),

            child: Form(

              key: _formKey,

              child: ListView(

                children: [

                  TextFormField(

                    controller:
                        nameController,

                    decoration:
                        const InputDecoration(
                      labelText:
                          'Name',
                    ),

                    validator: (v) {

                      if (v == null ||
                          v.trim().isEmpty) {

                        return 'Required';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 12,
                  ),

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
                          v.trim().length <
                              10) {

                        return 'Invalid number';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  dropdown(
                    'Gender',
                    selectedGender,
                    [
                      'Male',
                      'Female',
                    ],
                    (v) {

                      setState(() {
                        selectedGender = v;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 12,
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
                        selectedWorkType = v;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 12,
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
                        selectedState = v;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 12,
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
                    height: 24,
                  ),

                  const Text(
                    'Wages',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
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
                    '6 AM – 10 PM',
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

                  const SizedBox(
                    height: 16,
                  ),

                  TextFormField(

                    controller:
                        notesController,

                    minLines: 3,
                    maxLines: 5,

                    decoration:
                        const InputDecoration(
                      labelText:
                          'Notes',
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  SizedBox(

                    height: 50,

                    child: ElevatedButton(

                      onPressed:

                          isSaving
                              ? null
                              : saveWorker,

                      child:

                          isSaving

                              ? const CircularProgressIndicator()

                              : Text(

                                  widget.worker ==
                                          null

                                      ? 'Save Worker'

                                      : 'Update Worker',
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget dropdown(
    String label,
    String currentValue,
    List<String> items,
    ValueChanged<String>
        onChanged,
  ) {

    return DropdownButtonFormField<
        String>(

      initialValue:
          currentValue,

      decoration:
          InputDecoration(
        labelText: label,
      ),

      items:
          items.map(
        (e) {

          return DropdownMenuItem(
            value: e,
            child: Text(e),
          );
        },
      ).toList(),

      onChanged: (v) {

        if (v != null) {
          onChanged(v);
        }
      },
    );
  }

  Widget wageField(
    TextEditingController
        controller,
    String label,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: TextFormField(

        controller: controller,

        keyboardType:
            TextInputType.number,

        decoration:
            InputDecoration(
          labelText: label,
          prefixText: '₹ ',
        ),
      ),
    );
  }
}