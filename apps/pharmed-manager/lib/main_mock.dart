import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/flavor/app_flavor.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  FlavorConfig.initialize(AppFlavor.mock);
  await Hive.initFlutter();
  runApp(ManagerApp(prefs: prefs));
}
