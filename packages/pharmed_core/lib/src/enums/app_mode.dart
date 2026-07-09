import 'package:pharmed_ui/pharmed_ui.dart';

enum AppMode {
  admin,
  manager,
  client;

  String get label {
    switch (this) {
      case AppMode.admin:
        return contextlessL10n().enumCore_appModeAdmin;
      case AppMode.manager:
        return contextlessL10n().enumCore_appModeManager;
      case AppMode.client:
        return contextlessL10n().enumCore_appModeStation;
    }
  }

  bool get isAdmin => this == AppMode.admin;
  bool get isManager => this == AppMode.manager;
  bool get isClient => this == AppMode.client;

  static List<AppMode> selectableModes = [AppMode.manager, AppMode.client];
}
