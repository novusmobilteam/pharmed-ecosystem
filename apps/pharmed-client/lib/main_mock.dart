import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_client/core/providers/auth_providers.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'core/flavor/app_flavor.dart';
import 'core/logging/app_logging.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await initWindowManager();

  FlavorConfig.initialize(AppFlavor.mock);
  await Hive.initFlutter();
  await initAppLogging(verbose: true);

  // Mock test için cache'i temizle
  final container = ProviderContainer();

  container.dispose();

  runApp(
    ProviderScope(overrides: [authRepositoryProvider.overrideWithValue(AuthMockRepository())], child: const MyApp()),
  );
}
