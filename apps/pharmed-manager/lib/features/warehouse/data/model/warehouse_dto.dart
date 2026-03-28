import '../../../../core/core.dart';
import '../../../user/user.dart';
import '../../domain/entity/warehouse.dart';

class WarehouseDTO {
  final int? id;
  final int? code;
  final String? name;
  final int? userId;
  final UserDTO? user;
  final int? warehouseKindId;
  final bool isActive;

  const WarehouseDTO({
    this.id,
    this.code,
    this.name,
    this.userId,
    this.user,
    this.warehouseKindId,
    this.isActive = true,
  });

  factory WarehouseDTO.fromJson(Map<String, dynamic> json) => WarehouseDTO(
        id: json['id'] as int?,
        code: json['code'] as int?,
        name: json['name'] as String?,
        userId: json['userId'] as int?,
        user: json['user'] != null ? UserDTO.fromJson(json['user']) : null,
        warehouseKindId: json['warehouseKindId'] as int?,
        isActive: (json['isActive'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'userId': user?.id,
        'isActive': isActive,
        'warehouseKindId': warehouseKindId,
      };

  Warehouse toEntity() {
    return Warehouse(
      id: id,
      code: code,
      name: name,
      user: user?.toEntity(),
      isActive: isActive,
      type: warehouseTypeFromId(warehouseKindId),
    );
  }

  /// Mock factory for test data generation
  static WarehouseDTO mockFactory(int id, {bool withNested = true}) {
    final warehouseNames = [
      'Ana Depo',
      'Soğuk Depo',
      'Narkotik Depo',
      'Acil Depo',
      'Yedek Depo',
      'Cerrahi Malzeme',
      'Tıbbi Sarf',
      'İlaç Deposu A',
      'İlaç Deposu B',
      'Karantina',
    ];
    return WarehouseDTO(
      id: id,
      code: 1000 + id,
      name: warehouseNames[(id - 1) % warehouseNames.length],
      userId: id,
      user: null, // Avoid circular dependency
      warehouseKindId: ((id - 1) % 3) + 1,
      isActive: true,
    );
  }
}
