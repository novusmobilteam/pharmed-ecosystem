import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'main_production.dart' as production;
import 'session_timeout_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // await windowManager.ensureInitialized();

  // WindowOptions windowOptions = const WindowOptions(
  //   fullScreen: true,
  //   title: 'Pharmed',
  //   // You can also set other options like:
  //   // size: Size(800, 600),
  //   // center: true,
  //   // minimumSize: Size(400, 300),
  //   // maximumSize: Size(1200, 900),
  //   skipTaskbar: false,
  //   titleBarStyle: TitleBarStyle.normal,
  // );

  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  //   // await windowManager.setFullScreen(true);
  // });

  production.start(prefs);
  // if (!kDebugMode) {
  //   await development.start(prefs);
  // } else {
  //   production.start(prefs);
  // }

  HttpOverrides.global = MyHttpOverrides();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pharmed',
      theme: MaterialTheme().light(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return SessionTimeoutManager(
          duration: const Duration(minutes: 150),
          child: child!,
        );
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('tr', 'TR'),
        const Locale('en', 'US'),
      ],
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
