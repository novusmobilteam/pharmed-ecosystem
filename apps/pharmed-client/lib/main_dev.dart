import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:pharmed_client/main.dart';
import 'core/flavor/app_flavor.dart';
import 'core/logging/app_logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await initWindowManager();

  FlavorConfig.initialize(AppFlavor.dev);
  await Hive.initFlutter();
  // final container = ProviderContainer();
  // await container.read(cabinLocaleDataSourceProvider).clearAll();
  // await appSettingsCache.resetSetup();
  await initAppLogging(verbose: true);

  runApp(const ProviderScope(child: MyApp()));
}
