import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:provider/provider.dart';

import 'core/cache/app_settings_cache.dart';
import 'core/providers/network_providers.dart';
import 'core/providers/auth_providers.dart';
import 'core/providers/core_providers.dart';
import 'core/providers/datasource_providers.dart';
import 'core/providers/repository_providers.dart';
import 'core/providers/usecase_providers.dart';
import 'core/router/app_router.dart';
import 'features/auth/auth.dart';
import 'features/settings/notifier/settings_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  FlavorConfig.initialize(AppFlavor.dev); // geliştirme için
  runApp(ClientApp());
}

class ClientApp extends StatelessWidget {
  const ClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...CoreProviders.providers(),
        ...NetworkProviders.providers(),
        ...AuthProviders.providers(),
        ...DatasourceProviders.providers(),
        ...RepositoryProviders.providers(),
        ...UsecaseProviders.providers(),
        ChangeNotifierProvider<SettingsNotifier>(
          create: (ctx) => SettingsNotifier(
            cache: ctx.read<AppSettingsCache>(),
            tokenHolder: ctx.read<TokenHolder>(),
            getSystemParameters: ctx.read<GetSystemParametersUseCase>(),
            getCabins: ctx.read<GetCabinsUseCase>(),
            authNotifier: ctx.read<AuthNotifier>(),
          ),
        ),
      ],
      child: InputFieldTheme(
        style: InputFieldStyle.client,
        child: Consumer<SettingsNotifier>(
          builder: (context, settings, _) {
            setCurrentLocale(settings.language.locale);

            return MaterialApp(
              title: 'Pharmed Client',
              theme: MedTheme.client(),
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
