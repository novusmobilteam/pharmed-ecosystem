import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_client/main.dart';
import 'core/flavor/app_flavor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.initialize(AppFlavor.prod);
  await Hive.initFlutter();
  runApp(const ProviderScope(child: MyApp()));
}
