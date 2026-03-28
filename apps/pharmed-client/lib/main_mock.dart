import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/flavor/app_flavor.dart';
import 'core/cache/hive_cache.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.initialize(AppFlavor.mock);
  await AppBootstrap.init();
  runApp(const ProviderScope(child: MyApp()));
}
