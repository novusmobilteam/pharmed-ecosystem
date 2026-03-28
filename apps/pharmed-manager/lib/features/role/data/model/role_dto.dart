import '../../domain/entity/role.dart';

class RoleDTO {
  final int? id;
  final String? name;
  final bool isActive;

  const RoleDTO({
    this.id,
    this.name,
    this.isActive = true,
  });

  factory RoleDTO.fromJson(Map<String, dynamic> json) => RoleDTO(
        id: json['id'] as int?,
        name: json['name'] as String?,
        isActive: (json['isActive'] as bool?) ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isActive': isActive,
      };

  RoleDTO copyWith({
    int? id,
    String? name,
    bool? isActive,
  }) {
    return RoleDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  Role toEntity() => Role(
        id: id,
        name: name,
        isActive: isActive,
      );

  /// Mock factory for test data generation
  static RoleDTO mockFactory(int id) {
    final roles = ['Admin', 'Eczacı', 'Hemşire', 'Doktor', 'Depo Sorumlusu', 'Teknisyen'];
    return RoleDTO(
      id: id,
      name: roles[(id - 1) % roles.length],
      isActive: true,
    );
  }
}
