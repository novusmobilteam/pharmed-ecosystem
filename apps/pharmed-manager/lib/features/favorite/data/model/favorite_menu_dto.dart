import '../../domain/entity/favorite_menu.dart';

class FavoriteMenuDTO {
  final int? menuId;
  final int? userId;

  FavoriteMenuDTO({this.menuId, this.userId});

  factory FavoriteMenuDTO.fromJson(Map<String, dynamic> json) {
    return FavoriteMenuDTO(
      menuId: json['menuId'] as int?,
      userId: json['userId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuId': menuId,
    };
  }

  FavoriteMenu toEntity() {
    return FavoriteMenu(
      menuId: menuId,
      userId: userId,
    );
  }
}
