import 'package:flutter/widgets.dart';
import 'package:pharmed_manager/core/auth/auth_manager_notifier.dart';

import '../../features/settings/presentation/notifier/settings_notifier.dart';

class RouterNotifier extends ChangeNotifier {
  final SettingsNotifier settings;
  final AuthManagerNotifier auth;

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
