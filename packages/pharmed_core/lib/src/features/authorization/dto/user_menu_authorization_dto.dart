class UserMenuAuthorizationDto {
  final int? id;
  final int? userId;
  final List<int>? menuIds;

  UserMenuAuthorizationDto({this.id, this.userId, this.menuIds});

  UserMenuAuthorizationDto copyWith({int? id, int? userId, List<int>? menuIds}) {
    return UserMenuAuthorizationDto(id: id ?? this.id, userId: userId ?? this.userId, menuIds: menuIds ?? this.menuIds);
  }

  factory UserMenuAuthorizationDto.fromJson(Map<String, dynamic> json) {
    return UserMenuAuthorizationDto(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      menuIds: (json['menuIds'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'menuIds': menuIds};
  }
}
