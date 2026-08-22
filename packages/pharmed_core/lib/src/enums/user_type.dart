import 'package:pharmed_ui/pharmed_ui.dart';

enum UserType {
  normal(1),
  timeBased(2),
  temporary(3);

  final int id;

  const UserType(this.id);

  String get label {
    switch (this) {
      case UserType.normal:
        return contextlessL10n().enumCore_userTypeUnlimited;
      case UserType.timeBased:
        return contextlessL10n().user_categoryTimeBasedLabel;
      case UserType.temporary:
        return contextlessL10n().user_categoryTemporaryLabel;
    }
  }

  static UserType fromId(int? id) {
    return UserType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => UserType.normal,
    );
  }
}
