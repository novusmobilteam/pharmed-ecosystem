import '../../domain/entity/dosage_form.dart';

class DosageFormDTO {
  final int? id;
  final String? name;
  final bool isActive;

  const DosageFormDTO({
    this.id,
    this.name,
    this.isActive = true,
  });

  factory DosageFormDTO.fromJson(Map<String, dynamic> json) {
    return DosageFormDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
    };
  }

  DosageForm toEntity() {
    return DosageForm(
      id: id,
      name: name,
      isActive: isActive,
    );
  }

  /// Mock factory for test data generation
  static DosageFormDTO mockFactory(int id) {
    return DosageFormDTO(
      id: id,
      name: 'Dozaj Form $id',
      isActive: true,
    );
  }
}
