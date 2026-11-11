import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/main.dart';
import 'core/flavor/app_flavor.dart';
import 'core/logging/app_logging.dart';
import 'core/storage/client_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await initWindowManager();
  FlavorConfig.initialize(AppFlavor.prod);
  await initAppLogging(verbose: false);
  // prod'da test cihazı yoktur; varsayılan Hive klasörü açılır.
  await initClientStorage();
  runApp(const ProviderScope(child: MyApp()));
}
