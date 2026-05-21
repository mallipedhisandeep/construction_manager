import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../localization/app_strings.dart';
import '../providers/app_providers.dart';
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

// ============================================================
// HOME SCREEN
// ============================================================
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int workerCount = 0, activeSiteCount = 0, privateWorkerCount = 0;
  bool loading = true;

  @override
  void initState() { super.initState(); _loadStats(); }

  Future<void> _loadStats() async {
    try {
      final w = await WorkerDao().getAllWorkers();
      final s = await SiteDao().getAllSites();
      final p = await PrivateWorkerDao().getAll();
      if (mounted) setState(() {
        workerCount = w.length;
        activeSiteCount = s.where((x) => x.status == 'Active').length;
        privateWorkerCount = p.length;
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTelugu = ref.watch(languageProvider);
    final s = S(isTelugu);
    final cs = Theme.of(context).colorScheme;
    final user = Supabase.instance.client.auth.currentUser;

    final modules = [
      (title: s.attendance,     icon: Icons.calendar_month_rounded,  route: '/attendance',       color: Colors.deepOrange),
      (title: s.workers,        icon: Icons.groups_rounded,           route: '/workers',          color: Colors.blue),
      (title: s.sites,          icon: Icons.location_city_rounded,    route: '/sites',            color: Colors.green),
      (title: s.privateWorkers, icon: Icons.engineering_rounded,      route: '/private-workers',  color: Colors.purple),
      (title: s.privateWork,    icon: Icons.work_rounded,             route: '/private-work',     color: Colors.teal),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(s.appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        actions: [
          // Language toggle button
          TextButton(
            onPressed: () => ref.read(languageProvider.notifier).state = !isTelugu,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isTelugu ? 'EN' : 'తెలుగు',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: s.signOut,
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
            // Welcome card
            Card(
              color: cs.primary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(children: [
                  const Icon(Icons.construction_rounded, color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.welcome, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    Text(
                      user?.email?.split('@').first.toUpperCase() ?? 'Admin',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ])),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Stats
            loading
              ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              : Row(children: [
                  _statCard(s.workers,     workerCount,       Icons.groups_rounded,       Colors.blue,      context),
                  const SizedBox(width: 10),
                  _statCard(s.activeSites, activeSiteCount,   Icons.domain_rounded,       Colors.green,     context),
                  const SizedBox(width: 10),
                  _statCard(s.contractors, privateWorkerCount, Icons.engineering_rounded, Colors.purple,    context),
                ]),
            const SizedBox(height: 20),

            Text(s.modules, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Module grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.2,
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
                      padding: const EdgeInsets.all(14),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: m.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                          child: Icon(m.icon, size: 30, color: m.color),
                        ),
                        const SizedBox(height: 8),
                        Text(m.title, textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ]),
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
    return Expanded(child: Card(child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center, maxLines: 2),
      ]),
    )));
  }
}
