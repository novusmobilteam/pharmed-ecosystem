import 'package:flutter/widgets.dart';

import '../../features/settings/presentation/notifier/settings_notifier.dart';
import '../storage/auth/auth_storage_notifier.dart';

class RouterNotifier extends ChangeNotifier {
  final SettingsNotifier settings;
  final AuthStorageNotifier auth;

  RouterNotifier({required this.settings, required this.auth}) {
    settings.addListener(notifyListeners);
    auth.addListener(notifyListeners);
  }

  @override
  void dispose() {
    settings.removeListener(notifyListeners);
    auth.removeListener(notifyListeners);
    super.dispose();
  }
}
