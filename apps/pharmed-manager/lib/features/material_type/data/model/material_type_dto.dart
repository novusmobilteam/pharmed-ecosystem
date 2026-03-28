import '../../domain/entity/material_type.dart';

class MaterialTypeDTO {
  final int? id;
  final String? name;
  final bool isActive;

  MaterialTypeDTO({
    this.id,
    this.name,
    this.isActive = true,
  });

  factory MaterialTypeDTO.fromJson(Map<String, dynamic> json) {
    return MaterialTypeDTO(
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

  MaterialType toEntity() {
    return MaterialType(
      id: id,
      name: name,
      isActive: isActive,
    );
  }

  /// Mock factory for test data generation
  static MaterialTypeDTO mockFactory(int id) {
    final types = ['İlaç', 'Tıbbi Sarf', 'Kit', 'Serum', 'Enjektör', 'Eldiven', 'Maske'];

    return MaterialTypeDTO(
      id: id,
      name: types[(id - 1) % types.length],
      isActive: true,
    );
  }
}
