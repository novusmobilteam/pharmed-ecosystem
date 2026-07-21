import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';

import 'package:pharmed_manager/features/home/notifier/home_notifier.dart';
import 'package:pharmed_manager/features/settings/notifier/settings_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/core.dart';
import 'core/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  FlavorConfig.initialize(AppFlavor.dev); // geliştirme için
  await Hive.initFlutter();
  runApp(ManagerApp(prefs: prefs));
}

class ManagerApp extends StatelessWidget {
  const ManagerApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...CoreProviders.providers(prefs: prefs),
        ...AuthProviders.providers(),
        ...DatasourceProviders.providers(),
        ...RepositoryProviders.providers(),
        ...UsecaseProviders.providers(),
        ChangeNotifierProvider(
          create: (ctx) => HomeNotifier(getFilteredMenusUseCase: ctx.read(), authNotifier: ctx.read()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SettingsNotifier(repository: ctx.read(), cache: ctx.read(), tokenHolder: ctx.read()),
        ),
      ],
      child: InputFieldTheme(
        style: InputFieldStyle.manager,
        child: Consumer<SettingsNotifier>(
          builder: (context, settings, _) {
            setCurrentLocale(settings.language.locale);

            return MaterialApp(
              title: 'Pharmed Manager',
              theme: MedTheme.manager(),
              debugShowCheckedModeBanner: false,
              locale: settings.language.locale,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('tr'), Locale('en'), Locale('fr')],
              home: AppRouter(),
            );
          },
        ),
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
