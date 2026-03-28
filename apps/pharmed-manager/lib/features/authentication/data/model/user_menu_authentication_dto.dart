class UserMenuAuthenticationDTO {
  final int? id;
  final int? userId;
  final List<int>? menuIds;

  UserMenuAuthenticationDTO({
    this.id,
    this.userId,
    this.menuIds,
  });

  UserMenuAuthenticationDTO copyWith({
    int? id,
    int? userId,
    List<int>? menuIds,
  }) {
    return UserMenuAuthenticationDTO(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      menuIds: menuIds ?? this.menuIds,
    );
  }

  factory UserMenuAuthenticationDTO.fromJson(Map<String, dynamic> json) {
    return UserMenuAuthenticationDTO(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      menuIds: (json['menuIds'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'menuIds': menuIds,
    };
  }
}
