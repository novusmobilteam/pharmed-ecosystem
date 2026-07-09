import 'package:pharmed_ui/pharmed_ui.dart';

enum Status { active, passive }

extension StatusExtension on Status {
  String get label {
    switch (this) {
      case Status.active:
        return contextlessL10n().enumCore_statusActive;
      case Status.passive:
        return contextlessL10n().enumCore_statusPassive;
    }
  }

  static Status fromString(String? value) {
    if (value == null) {
      return Status.active;
    } else {
      switch (value.toLowerCase()) {
        case 'aktif':
          return Status.active;
        case 'pasif':
          return Status.passive;
        default:
          throw Exception('Invalid status string');
      }
    }
  }

  bool get isActive {
    return this == Status.active;
  }
}

Status statusFromBool(bool value) {
  return value ? Status.active : Status.passive;
}
