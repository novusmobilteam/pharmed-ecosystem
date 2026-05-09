import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:pharmed_manager/core/theme/app_theme.dart';

import 'package:pharmed_manager/features/home/notifier/home_notifier.dart';
import 'package:provider/provider.dart';

import 'core/providers/providers.dart';
import 'core/routing/app_router.dart';
import 'features/role/role.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.initialize(AppFlavor.dev); // geliştirme için
  await Hive.initFlutter();
  runApp(const ManagerApp());
}

class ManagerApp extends StatelessWidget {
  const ManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...CoreProviders.providers(),
        ...AuthProviders.providers(),
        ...DatasourceProviders.providers(),
        ...RepositoryProviders.providers(),
        ...UsecaseProviders.providers(),
        ChangeNotifierProvider(
          create: (ctx) => HomeNotifier(getFilteredMenusUseCase: ctx.read(), authNotifier: ctx.read()),
        ),
      ],
      child: MaterialApp(
        title: 'Pharmed Manager',
        theme: MaterialTheme().light(),
        debugShowCheckedModeBanner: false,
        home: AppRouter(),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('tr', 'TR')],
      ),
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
