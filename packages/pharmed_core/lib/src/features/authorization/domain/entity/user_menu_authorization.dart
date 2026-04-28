import 'package:pharmed_manager/core/core.dart';

class UserMenuAuthorization {
  final int? id;
  final User? user;

  /// Sunucudan gelen orijinal yetki ID’leri
  final Set<int> menuIdsOriginal;

  /// UI’da geçici olarak değiştirilen yetki ID’leri
  final Set<int> menuIdsPending;

  const UserMenuAuthorization({this.id, this.user, Set<int>? menuIdsOriginal, Set<int>? menuIdsPending})
    : menuIdsOriginal = menuIdsOriginal ?? const <int>{},
      menuIdsPending = menuIdsPending ?? const <int>{};

  /// Değişiklik var mı?
  bool get isDirty => menuIdsOriginal.length != menuIdsPending.length || !menuIdsOriginal.containsAll(menuIdsPending);

  /// Pending’i tamamen değiştir
  UserMenuAuthorization withPending(Set<int> ids) => copyWith(menuIdsPending: {...ids});

  UserMenuAuthorization toggle(int menuId) {
    final n = Set<int>.from(menuIdsPending);
    n.contains(menuId) ? n.remove(menuId) : n.add(menuId);
    return copyWith(menuIdsPending: n);
  }

  UserMenuAuthorization reset() => copyWith(menuIdsPending: {...menuIdsOriginal});

  UserMenuAuthorization commit() => copyWith(menuIdsOriginal: {...menuIdsPending});

  UserMenuAuthorization copyWith({int? id, User? user, Set<int>? menuIdsOriginal, Set<int>? menuIdsPending}) {
    return UserMenuAuthorization(
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
