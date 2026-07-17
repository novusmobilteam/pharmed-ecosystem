import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initWindowManager() async {
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    fullScreen: true,
    alwaysOnTop: false,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.maximize();
    await windowManager.focus();
    //await windowManager.setPreventClose(true);
  });
}
