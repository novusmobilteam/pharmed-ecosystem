import '../../data/model/favorite_menu_dto.dart';

class FavoriteMenu {
  final int? menuId;
  final int? userId;

  FavoriteMenu({this.menuId, this.userId});

  FavoriteMenuDTO toDTO() {
    return FavoriteMenuDTO(
      menuId: menuId,
      userId: userId,
    );
  }
}
