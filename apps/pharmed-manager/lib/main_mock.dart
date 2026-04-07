import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'core/flavor/app_flavor.dart';
import 'core/providers/providers.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.initialize(AppFlavor.mock);
  await Hive.initFlutter();
  MedLogger.configure(verboseLogging: true);

  runApp(
    ProviderScope(overrides: [authRepositoryProvider.overrideWithValue(AuthMockRepository())], child: const MyApp()),
  );
}
