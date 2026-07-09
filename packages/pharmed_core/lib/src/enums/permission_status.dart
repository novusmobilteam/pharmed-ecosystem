import 'package:pharmed_ui/pharmed_ui.dart';

enum PermissionStatus {
  allowed,
  denied;

  String get label {
    switch (this) {
      case PermissionStatus.allowed:
        return contextlessL10n().enumCore_permissionCan;
      case PermissionStatus.denied:
        return contextlessL10n().enumCore_permissionCannot;
    }
  }

  bool get isAllowed {
    return this == PermissionStatus.allowed;
  }
}

PermissionStatus permissionStatusFromBool(bool value) {
  return value ? PermissionStatus.allowed : PermissionStatus.denied;
}
