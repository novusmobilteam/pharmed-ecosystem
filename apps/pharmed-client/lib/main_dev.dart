import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_client/main.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'core/cache/app_settings_cache.dart';
import 'core/flavor/app_flavor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.initialize(AppFlavor.dev);
  await Hive.initFlutter();
  MedLogger.configure(verboseLogging: true);
  //await appSettingsCache.resetSetup();
  runApp(const ProviderScope(child: MyApp()));
}
