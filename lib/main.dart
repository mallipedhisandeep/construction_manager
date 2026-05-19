import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/workers/presentation/workers_list_page.dart';
import 'features/attendance/presentation/attendance_home_page.dart';
import 'features/sites/presentation/sites_list_page.dart';
import 'features/private_workers/presentation/private_workers_list_page.dart';
import 'features/private_work/presentation/private_work_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(const ConstructionManagerApp());
}

class ConstructionManagerApp extends StatelessWidget {
  const ConstructionManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Construction Manager',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Construction Manager'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuButton(context, 'Daily Attendance'),
          _menuButton(context, 'Workers Details'),
          _menuButton(context, 'Sites'),
          _menuButton(context, 'Private Workers'),
          _menuButton(context, 'Private Work'),
          _menuButton(context, 'Suppliers'),
          _menuButton(context, 'Goods'),
          _menuButton(context, 'Money Tracking'),
          _menuButton(context, 'Reports'),
        ],
      ),
    );
  }
}

Widget _menuButton(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () {
        if (title == 'Workers Details') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WorkersListPage(),
            ),
          );
        } else if (title == 'Daily Attendance') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AttendanceHomePage(),
            ),
          );
        } else if (title == 'Sites') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SitesListPage(),
            ),
          );
        } else if (title == 'Private Workers') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PrivateWorkersListPage(),
            ),
          );
        } else if (title == 'Private Work') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PrivateWorkListPage(),
            ),
          );
        }
      },
      child: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
    ),
  );
}