import '../../domain/entity/drug_class.dart';

class DrugClassDTO {
  final int? id;
  final String? name;
  final bool? isActive;

  const DrugClassDTO({
    this.id,
    this.name,
    this.isActive,
  });

  factory DrugClassDTO.fromJson(Map<String, dynamic> json) {
    return DrugClassDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
    };
  }

  DrugClassDTO copyWith({
    int? id,
    String? name,
    bool? isActive,
  }) {
    return DrugClassDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  DrugClass toEntity() {
    return DrugClass(
      id: id,
      name: name,
      isActive: isActive ?? true,
    );
  }

  /// Mock factory for test data generation
  static DrugClassDTO mockFactory(int id) {
    final classes = ['OTC', 'Rx', 'Narkotik', 'Psikotrop', 'Özel', 'Kan Ürünü', 'Biyolojik', 'Aşı'];

    return DrugClassDTO(
      id: id,
      name: classes[(id - 1) % classes.length],
      isActive: true,
    );
  }
}
