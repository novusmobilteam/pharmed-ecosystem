class RoleMenuAuthorizationDto {
  final int? id;
  final int? roleId;
  final List<int>? menuIds;

  RoleMenuAuthorizationDto({this.id, this.roleId, this.menuIds});

  RoleMenuAuthorizationDto copyWith({int? id, int? roleId, List<int>? menuIds}) {
    return RoleMenuAuthorizationDto(id: id ?? this.id, roleId: roleId ?? this.roleId, menuIds: menuIds ?? this.menuIds);
  }

  factory RoleMenuAuthorizationDto.fromJson(Map<String, dynamic> json) {
    return RoleMenuAuthorizationDto(
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
}
