enum PermissionStatus {
  allowed,
  denied;

  String get label {
    switch (this) {
      case PermissionStatus.allowed:
        return 'Yapabilir';
      case PermissionStatus.denied:
        return 'Yapamaz';
    }
  }

  bool get isAllowed {
    return this == PermissionStatus.allowed;
  }
}

PermissionStatus permissionStatusFromBool(bool value) {
  return value ? PermissionStatus.allowed : PermissionStatus.denied;
}
