import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class Warning {
  final int? id;
  final WarningSubject? subject;
  final String? text;
  final bool isActive;
  final DateTime? createdDate;

  const Warning({this.id, this.subject, this.text, this.isActive = true, this.createdDate});

  Status get status => isActive ? Status.active : Status.passive;

  Warning updateText(String? text) {
    return copyWith(text: text);
  }

  Warning updateStatus(Status? newStatus) {
    return copyWith(isActive: newStatus?.isActive ?? true);
  }

  Warning updateSubject(WarningSubject? subject) {
    return copyWith(subject: subject);
  }

  // Validasyon metodları
  bool get isValid => text?.trim().isNotEmpty == true;
  String? get textError {
    if (text == null || text!.trim().isEmpty) return contextlessL10n().dataGuard_warningTextRequired;
    return null;
  }

  Warning copyWith({int? id, WarningSubject? subject, String? text, bool? isActive}) {
    return Warning(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      text: text ?? this.text,
      isActive: isActive ?? this.isActive,
    );
  }
}
