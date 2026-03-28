import '../../../../core/core.dart';
import '../../domain/entity/warning.dart';

class WarningDTO {
  final int? id;
  final int? warningSubjectId;
  final String? text;
  final bool isActive;

  const WarningDTO({this.id, this.warningSubjectId, this.text, this.isActive = true});

  factory WarningDTO.fromJson(Map<String, dynamic> json) => WarningDTO(
    id: json['id'] as int?,
    warningSubjectId: json['warningSubjectId'] as int?,
    text: json['text'] as String?,
    isActive: (json['isActive'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {'id': id, 'warningSubjectId': warningSubjectId, 'text': text, 'isActive': isActive};

  Warning toEntity() =>
      Warning(id: id, subject: WarningSubject.fromId(warningSubjectId), text: text, isActive: isActive);

  /// Mock factory for test data generation
  static WarningDTO mockFactory(int id) {
    final warnings = [
      'Minimum stok altında',
      'Son kullanma tarihi yaklaşıyor',
      'Kritik stok',
      'Narkotik kontrol gerekli',
      'Soğuk zincir uyarısı',
      'Bekleyen sipariş',
    ];
    return WarningDTO(id: id, warningSubjectId: id, text: warnings[(id - 1) % warnings.length], isActive: true);
  }
}
