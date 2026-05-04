import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/core.dart';
import 'core/flavor/app_flavor.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.initialize(AppFlavor.dev);
  MedLogger.configure(verboseLogging: true);
  await Hive.initFlutter();
  runApp(const ManagerApp());
}
