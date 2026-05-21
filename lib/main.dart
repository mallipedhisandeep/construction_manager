import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (
    FlutterErrorDetails details,
  ) {
    debugPrint(
      'FLUTTER ERROR => ${details.exception}',
    );
  };

  await Supabase.initialize(

    url:
        'YOUR_SUPABASE_PROJECT_URL',

    anonKey:
        'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(
    const ProviderScope(
      child:
          ConstructionManagerApp(),
    ),
  );
}

class ConstructionManagerApp
    extends StatelessWidget {

  const ConstructionManagerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(

      debugShowCheckedModeBanner:
          false,

      title:
          'Construction Manager',

      routerConfig:
          appRouter,

      theme: ThemeData(
        colorSchemeSeed:
            Colors.deepPurple,
        useMaterial3: true,
      ),
    );
  }
}