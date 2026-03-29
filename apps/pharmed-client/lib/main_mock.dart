import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/providers/auth_providers.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'core/flavor/app_flavor.dart';
import 'core/cache/hive_cache.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.initialize(AppFlavor.mock);
  await AppBootstrap.init();

  runApp(
    ProviderScope(overrides: [authRepositoryProvider.overrideWithValue(AuthMockRepository())], child: const MyApp()),
  );
}
