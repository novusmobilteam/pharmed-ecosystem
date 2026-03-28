import '../../../../core/core.dart';
import '../../domain/entity/unit.dart';

class UnitDTO {
  final int? id;
  final String? name;
  final bool? isActive;

  UnitDTO({
    this.id,
    this.name,
    this.isActive,
  });

  factory UnitDTO.fromJson(Map<String, dynamic> json) {
    return UnitDTO(
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

  UnitDTO copyWith({
    int? id,
    String? name,
    bool? isActive,
  }) {
    return UnitDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  Unit toEntity() {
    return Unit(
      id: id,
      name: name,
      status: statusFromBool(isActive ?? false),
    );
  }

  /// Mock factory for test data generation
  static UnitDTO mockFactory(int id) {
    final units = ['Adet', 'Kutu', 'mg', 'ml', 'gr', 'Ampul', 'Flakon', 'Tüp'];

    return UnitDTO(
      id: id,
      name: units[(id - 1) % units.length],
      isActive: true,
    );
  }
}
