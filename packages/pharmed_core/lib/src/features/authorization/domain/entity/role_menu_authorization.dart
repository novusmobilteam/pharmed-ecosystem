import 'package:pharmed_manager/core/core.dart';

class RoleMenuAuthorization {
  final int? id;
  final Role? role;

  /// Sunucudan gelen orijinal yetki ID’leri
  final Set<int> menuIdsOriginal;

  /// UI’da geçici olarak değiştirilen yetki ID’leri
  final Set<int> menuIdsPending;

  const RoleMenuAuthorization({this.id, this.role, Set<int>? menuIdsOriginal, Set<int>? menuIdsPending})
    : menuIdsOriginal = menuIdsOriginal ?? const <int>{},
      menuIdsPending = menuIdsPending ?? const <int>{};

  /// Değişiklik var mı?
  bool get isDirty => menuIdsOriginal.length != menuIdsPending.length || !menuIdsOriginal.containsAll(menuIdsPending);

  /// Pending’i tamamen değiştir
  RoleMenuAuthorization withPending(Set<int> ids) => copyWith(menuIdsPending: {...ids});

  RoleMenuAuthorization toggle(int id) {
    final n = {...menuIdsPending};
    if (n.contains(id)) {
      n.remove(id);
    } else {
      n.add(id);
    }
    return copyWith(menuIdsPending: n);
  }

  /// İptal → pending’i orijinale sar
  RoleMenuAuthorization reset() => copyWith(menuIdsPending: {...menuIdsOriginal});

  /// Kaydet sonrası → orijinali pending ile eşitle
  RoleMenuAuthorization commit() => copyWith(menuIdsOriginal: {...menuIdsPending});

  RoleMenuAuthorization copyWith({int? id, Role? role, Set<int>? menuIdsOriginal, Set<int>? menuIdsPending}) {
    return RoleMenuAuthorization(
      id: id ?? this.id,
      role: role ?? this.role,
      menuIdsOriginal: menuIdsOriginal ?? this.menuIdsOriginal,
      menuIdsPending: menuIdsPending ?? this.menuIdsPending,
    );
  }

  @override
  String toString() =>
      'UserMenuAuth(id:$id, role:${role?.id}, orig:${menuIdsOriginal.length}, pending:${menuIdsPending.length})';
}
