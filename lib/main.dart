import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

import 'core/auth/auth_service.dart';
import 'core/router/app_router.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (
    FlutterErrorDetails details,
  ) {
    debugPrint(
      'FLUTTER ERROR => ${details.exception}',
    );
  };

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform,
  );

  await AuthService.instance
      .signInAnonymously();

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