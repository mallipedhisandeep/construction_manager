import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/attendance/presentation/attendance_home_page.dart';
import '../../features/private_work/presentation/private_work_list_page.dart';
import '../../features/private_workers/presentation/private_workers_list_page.dart';
import '../../features/sites/presentation/sites_list_page.dart';
import '../../features/workers/presentation/workers_list_page.dart';
import '../../features/workers/data/worker_dao.dart';
import '../../features/sites/data/site_dao.dart';
import '../../features/private_workers/data/private_worker_dao.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final loggedIn = Supabase.instance.client.auth.currentUser != null;
    final goingLogin = state.matchedLocation == '/login';
    if (!loggedIn && !goingLogin) return '/login';
    if (loggedIn && goingLogin) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
    GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
    GoRoute(path: '/attendance', builder: (c, s) => const AttendanceHomePage()),
    GoRoute(path: '/workers', builder: (c, s) => const WorkersListPage()),
    GoRoute(path: '/sites', builder: (c, s) => const SitesListPage()),
    GoRoute(path: '/private-workers', builder: (c, s) => const PrivateWorkersListPage()),
    GoRoute(path: '/private-work', builder: (c, s) => const PrivateWorkListPage()),
  ],
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int workerCount = 0;
  int activeSiteCount = 0;
  int privateWorkerCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final workers = await WorkerDao().getAllWorkers();
      final sites = await SiteDao().getAllSites();
      final pw = await PrivateWorkerDao().getAll();
      if (mounted) setState(() {
        workerCount = workers.length;
        activeSiteCount = sites.where((s) => s.status == 'Active').length;
        privateWorkerCount = pw.length;
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = Supabase.instance.client.auth.currentUser;

    final modules = [
      (title: 'Daily Attendance', icon: Icons.calendar_month_rounded, route: '/attendance', color: Colors.deepOrange),
      (title: 'Workers', icon: Icons.groups_rounded, route: '/workers', color: Colors.blue),
      (title: 'Sites', icon: Icons.location_city_rounded, route: '/sites', color: Colors.green),
      (title: 'Private Workers', icon: Icons.engineering_rounded, route: '/private-workers', color: Colors.purple),
      (title: 'Private Work', icon: Icons.work_rounded, route: '/private-work', color: Colors.teal),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Construction Manager', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome Card
            Card(
              color: cs.primary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.construction_rounded, color: Colors.white, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome Back', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Text(
                            user?.email?.split('@').first.toUpperCase() ?? 'Admin',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stats Row
            loading
              ? const Center(child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ))
              : Row(
                  children: [
                    _statCard('Workers', workerCount, Icons.groups, Colors.blue, context),
                    const SizedBox(width: 12),
                    _statCard('Active Sites', activeSiteCount, Icons.domain, Colors.green, context),
                    const SizedBox(width: 12),
                    _statCard('Contractors', privateWorkerCount, Icons.engineering, Colors.purple, context),
                  ],
                ),
            const SizedBox(height: 20),

            const Text('Modules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),

            // Module Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: modules.length,
              itemBuilder: (context, i) {
                final m = modules[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.push(m.route),
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: m.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(m.icon, size: 32, color: m.color),
                          ),
                          const SizedBox(height: 10),
                          Text(m.title, textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, int count, IconData icon, Color color, BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
