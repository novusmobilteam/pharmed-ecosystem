import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/core.dart';
import 'core/flavor/app_flavor.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.initialize(AppFlavor.dev);
  await Hive.initFlutter();
  MedLogger.configure(verboseLogging: true);
  //await appSettingsCache.resetSetup();
  runApp(const ProviderScope(child: MyApp()));
}
