import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/role_menu_authentication.dart';

class RoleMenuAuthenticationDTO {
  final int? id;
  final int? roleId;
  final List<int>? menuIds;

  RoleMenuAuthenticationDTO({this.id, this.roleId, this.menuIds});

  RoleMenuAuthenticationDTO copyWith({int? id, int? roleId, List<int>? menuIds}) {
    return RoleMenuAuthenticationDTO(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      menuIds: menuIds ?? this.menuIds,
    );
  }

  factory RoleMenuAuthenticationDTO.fromJson(Map<String, dynamic> json) {
    return RoleMenuAuthenticationDTO(
      id: json['id'] as int?,
      roleId: json['roleId'] as int?,
      menuIds: (json['menuIds'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //'id': id,
      'roleId': roleId,
      'menuIds': menuIds,
    };
  }

  RoleMenuAuthentication toEntity() {
    final ids = (menuIds ?? const <int>[]).toSet();
    return RoleMenuAuthentication(
      id: id,
      role: Role.fromIdAndName(id: roleId),
      menuIdsOriginal: ids,
      menuIdsPending: {...ids},
    );
  }

  /// Mock factory for test data generation
  static RoleMenuAuthenticationDTO mockFactory(int id) {
    return RoleMenuAuthenticationDTO(id: id, roleId: ((id - 1) % 6) + 1, menuIds: [1, 2, 3, 4, 5]);
  }
}
