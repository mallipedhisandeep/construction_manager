import 'package:flutter/material.dart';
import '../../workers/data/worker_model.dart';

class AttendancePage extends StatelessWidget {
  final WorkerModel worker;

  const AttendancePage({
    super.key,
    required this.worker,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${worker.name} Attendance'),
      ),

      body: Center(
        child: Text(
          'Attendance screen for ${worker.name}',

          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}