import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pharmed_client/main.dart';
import 'core/flavor/app_flavor.dart';
import 'core/logging/app_logging.dart';
import 'core/storage/client_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await initWindowManager();

  FlavorConfig.initialize(AppFlavor.dev);
  await initAppLogging(verbose: true);
  // [SWREQ-CORE-005] Bilgisayar test sürümünde seçili test cihazının deposu.
  await initClientStorage();

  runApp(const ProviderScope(child: MyApp()));
}
