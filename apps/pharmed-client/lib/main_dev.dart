import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/cache/hive_cache.dart';
import 'package:pharmed_client/main.dart';
import 'core/flavor/app_flavor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.initialize(AppFlavor.dev);
  await AppBootstrap.init();
  runApp(const ProviderScope(child: MyApp()));
}
