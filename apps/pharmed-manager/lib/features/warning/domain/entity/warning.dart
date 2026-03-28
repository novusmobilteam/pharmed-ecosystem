import '../../../../core/core.dart';
import '../../data/model/warning_dto.dart';

class Warning implements TableData {
  final int? id;
  final WarningSubject? subject;
  final String? text;
  final bool isActive;

  const Warning({
    this.id,
    this.subject,
    this.text,
    this.isActive = true,
  });

  Status get status => isActive ? Status.active : Status.passive;

  @override
  List<String?> get content => [subject?.label, text, status.label];

  @override
  List get rawContent => content;

  @override
  List<String?> get titles => const ['Uyarı Konusu', 'Uyarı Metni', 'Durumu'];

  // Update metodları

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
    if (text == null || text!.trim().isEmpty) return 'Uyarı adı zorunludur';
    return null;
  }

  Warning copyWith({
    int? id,
    WarningSubject? subject,
    String? text,
    bool? isActive,
  }) {
    return Warning(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      text: text ?? this.text,
      isActive: isActive ?? this.isActive,
    );
  }

  WarningDTO toDTO() => WarningDTO(
        id: id,
        warningSubjectId: subject?.id,
        text: text,
        isActive: isActive,
      );
}
