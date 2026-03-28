import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum AppMode {
  admin('Admin'),
  manager('Yönetim'),
  client('İstasyon');

  final String label;

  const AppMode(this.label);

  bool get isAdmin => this == AppMode.admin;
  bool get isManager => this == AppMode.manager;
  bool get isClient => this == AppMode.client;

  static List<AppMode> selectableModes = [AppMode.manager, AppMode.client];
}

// extension AppModeExtension on AppMode {
//   String get routePath {
//     switch (this) {
//       case AppMode.admin:
//         return AppRoute.managerDashboard.path;
//       case AppMode.manager:
//         return AppRoute.managerDashboard.path;
//       case AppMode.client:
//         return AppRoute.clientDashboard.path;
//     }
//   }

//   IconData get icon {
//     switch (this) {
//       case AppMode.admin:
//         return PhosphorIcons.user();
//       case AppMode.manager:
//         return PhosphorIcons.buildings();
//       case AppMode.client:
//         return PhosphorIcons.deviceTablet();
//     }
//   }
// }
