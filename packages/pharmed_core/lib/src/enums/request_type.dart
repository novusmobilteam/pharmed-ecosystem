import 'package:pharmed_ui/pharmed_ui.dart';

enum RequestType {
  normal(1),
  emergency(2);

  final int id;

  const RequestType(this.id);

  static RequestType fromId(int? id) {
    return RequestType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => RequestType.normal,
    );
  }

  String get label {
    switch (this) {
      case RequestType.normal:
        return contextlessL10n().enumCore_requestTypeNormal;
      case RequestType.emergency:
        return contextlessL10n().enumCore_requestTypeUrgent;
    }
  }
}
