import '../../domain/entity/kit.dart';

class KitDTO {
  final int? id;
  final String? name;
  final String? normalizedName;
  final bool? isActive;

  KitDTO({
    this.id,
    this.name,
    this.normalizedName,
    this.isActive,
  });

  factory KitDTO.fromJson(Map<String, dynamic> json) {
    return KitDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      normalizedName: json['normalizedName'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'normalizedName': normalizedName,
      'isActive': isActive,
    };
  }

  Kit toEntity() => Kit(
        id: id,
        name: name,
        normalizedName: normalizedName,
        isActive: isActive,
      );

  KitDTO copyWith({
    int? id,
    String? name,
    String? normalizedName,
    bool? isActive,
  }) {
    return KitDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Mock factory for test data generation
  static KitDTO mockFactory(int id) {
    final kitNames = ['Acil Kit', 'Ameliyat Seti', 'Pansuman Seti', 'IV Set', 'Sütür Seti'];

    return KitDTO(
      id: id,
      name: kitNames[(id - 1) % kitNames.length],
      normalizedName: kitNames[(id - 1) % kitNames.length].toUpperCase(),
      isActive: true,
    );
  }
}
