import '../../../user/user.dart';
import '../../data/model/user_menu_authentication_dto.dart';

class UserMenuAuthentication {
  final int? id;
  final User? user;

  /// Sunucudan gelen orijinal yetki ID’leri
  final Set<int> menuIdsOriginal;

  /// UI’da geçici olarak değiştirilen yetki ID’leri
  final Set<int> menuIdsPending;

  const UserMenuAuthentication({
    this.id,
    this.user,
    Set<int>? menuIdsOriginal,
    Set<int>? menuIdsPending,
  })  : menuIdsOriginal = menuIdsOriginal ?? const <int>{},
        menuIdsPending = menuIdsPending ?? const <int>{};

  /// Değişiklik var mı?
  bool get isDirty => menuIdsOriginal.length != menuIdsPending.length || !menuIdsOriginal.containsAll(menuIdsPending);

  /// Pending’i tamamen değiştir
  UserMenuAuthentication withPending(Set<int> ids) => copyWith(menuIdsPending: {...ids});

  UserMenuAuthentication toggle(int menuId) {
    final n = Set<int>.from(menuIdsPending);
    n.contains(menuId) ? n.remove(menuId) : n.add(menuId);
    return copyWith(menuIdsPending: n);
  }

  UserMenuAuthentication reset() => copyWith(menuIdsPending: {...menuIdsOriginal});

  UserMenuAuthentication commit() => copyWith(menuIdsOriginal: {...menuIdsPending});

  factory UserMenuAuthentication.fromDTO({
    required UserMenuAuthenticationDTO? dto,
    required User user,
  }) {
    final ids = (dto?.menuIds ?? const <int>[]).whereType<int>().toSet();
    return UserMenuAuthentication(
      id: dto?.id,
      user: user,
      menuIdsOriginal: ids,
      menuIdsPending: {...ids},
    );
  }

  UserMenuAuthenticationDTO toDTO() {
    return UserMenuAuthenticationDTO(
      id: id,
      userId: user?.id,
      menuIds: menuIdsPending.toList(),
    );
  }

  UserMenuAuthentication copyWith({
    int? id,
    User? user,
    Set<int>? menuIdsOriginal,
    Set<int>? menuIdsPending,
  }) {
    return UserMenuAuthentication(
      id: id ?? this.id,
      user: user ?? this.user,
      menuIdsOriginal: menuIdsOriginal ?? this.menuIdsOriginal,
      menuIdsPending: menuIdsPending ?? this.menuIdsPending,
    );
  }

  @override
  String toString() =>
      'UserMenuAuth(id:$id, user:${user?.id}, orig:${menuIdsOriginal.length}, pending:${menuIdsPending.length})';
}
