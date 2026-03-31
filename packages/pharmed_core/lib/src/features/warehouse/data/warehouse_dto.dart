import 'package:pharmed_core/pharmed_core.dart';

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
}
