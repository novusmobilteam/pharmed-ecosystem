import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'core/providers/providers.dart';
import 'core/router/app_router.dart';
import 'core/services/service.dart';
import 'features/settings/presentation/notifier/settings_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final SerialPortLifecycleObserver _observer;
  final _navigatorKey = GlobalKey<NavigatorState>(); // <-- ekle

  @override
  void initState() {
    super.initState();
    _observer = SerialPortLifecycleObserver(ref.read(serialServiceProvider));
    WidgetsBinding.instance.addObserver(_observer);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(settingsNotifierProvider.select((s) => s.language.locale));
    return InputFieldTheme(
      style: InputFieldStyle.client,
      child: MaterialApp(
        title: 'Pharmed',
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey, // <-- ekle
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('tr'), Locale('en'), Locale('ar')],
        home: const AppRouter(),
        // builder: (context, child) {
        //   return Stack(
        //     children: [
        //       if (child != null) child,
        //       Positioned(
        //         right: 12,
        //         bottom: 12,
        //         child: _LogLauncherButton(navigatorKey: _navigatorKey), // <-- key'i geçir
        //       ),
        //     ],
        //   );
        // },
      ),
    );
  }
}

// class _LogLauncherButton extends StatelessWidget {
//   const _LogLauncherButton({required this.navigatorKey});
//   final GlobalKey<NavigatorState> navigatorKey;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: SizedBox(
//         width: 40,
//         height: 40,
//         child: FloatingActionButton.small(
//           heroTag: 'global_log_viewer',
//           backgroundColor: Colors.black.withOpacity(0.75),
//           elevation: 2,
//           onPressed: () {
//             // context yerine navigatorKey üzerinden push — Navigator garantili
//             navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const LogViewerScreen()));
//           },
//           child: const Icon(Icons.terminal, size: 18, color: Colors.greenAccent),
//         ),
//       ),
//     );
//   }
// }
