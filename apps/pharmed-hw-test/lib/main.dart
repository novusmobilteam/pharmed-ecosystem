// [IEC 62304] Saha test aracı — tıbbi cihaz yazılımının parçası değildir; kabin
// donanımını client ile aynı servis koduyla (pharmed_hardware) test eder.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'core/env.dart';
import 'features/cabin_type/cabin_type_page.dart';
import 'features/home/home_page.dart';
import 'features/login/login_page.dart';
import 'core/providers.dart';

/// Doğrudan `lib/main.dart` çalıştırılırsa dev ortamı kullanılır.
Future<void> main() async {
  AppEnv.init(flavor: 'dev', baseUrl: 'https://agena.novusyazilim.com/api');
  await run();
}

Future<void> run() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter('PharMedHwTest');
  runApp(const ProviderScope(child: HwTestApp()));
}

class HwTestApp extends ConsumerWidget {
  const HwTestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedIn = ref.watch(sessionProvider.select((s) => s.isLoggedIn));
    final hasCabinType = ref.watch(sessionProvider.select((s) => s.cabinType != null));
    return MaterialApp(
      title: 'PharMed Donanım Testi',
      theme: MedTheme.client(),
      debugShowCheckedModeBanner: false,
      locale: const Locale('tr'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr'), Locale('en'), Locale('fr')],
      home: !loggedIn
          ? const LoginPage()
          : hasCabinType
          ? const HomePage()
          : const CabinTypePage(),
    );
  }
}
