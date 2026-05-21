import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/attendance/presentation/attendance_home_page.dart';
import '../../features/private_work/presentation/private_work_list_page.dart';
import '../../features/private_workers/presentation/private_workers_list_page.dart';
import '../../features/sites/presentation/sites_list_page.dart';
import '../../features/workers/presentation/workers_list_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  redirect: (context, state) {
    final isLoggedIn =
        Supabase.instance.client.auth.currentUser != null;
    final isGoingToLogin = state.matchedLocation == '/login';

    if (!isLoggedIn && !isGoingToLogin) return '/login';
    if (isLoggedIn && isGoingToLogin) return '/';
    return null;
  },

  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: '/attendance',
      builder: (context, state) => const AttendanceHomePage(),
    ),

    GoRoute(
      path: '/workers',
      builder: (context, state) => const WorkersListPage(),
    ),

    GoRoute(
      path: '/sites',
      builder: (context, state) => const SitesListPage(),
    ),

    GoRoute(
      path: '/private-workers',
      builder: (context, state) => const PrivateWorkersListPage(),
    ),

    GoRoute(
      path: '/private-work',
      builder: (context, state) => const PrivateWorkListPage(),
    ),
  ],
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        title: 'Daily Attendance',
        icon: Icons.calendar_month,
        route: '/attendance',
      ),
      (
        title: 'Workers Details',
        icon: Icons.groups,
        route: '/workers',
      ),
      (
        title: 'Sites',
        icon: Icons.location_city,
        route: '/sites',
      ),
      (
        title: 'Private Workers',
        icon: Icons.engineering,
        route: '/private-workers',
      ),
      (
        title: 'Private Work',
        icon: Icons.work,
        route: '/private-work',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Construction Manager'),
        centerTitle: true,
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

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          final isTablet = constraints.maxWidth > 600;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : isTablet ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isDesktop ? 1.8 : 2.4,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => context.push(item.route),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 52,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
