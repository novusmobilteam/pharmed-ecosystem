import '../../../role/domain/entity/role.dart';
import '../../data/model/role_menu_authentication_dto.dart';

class RoleMenuAuthentication {
  final int? id;
  final Role? role;

  /// Sunucudan gelen orijinal yetki ID’leri
  final Set<int> menuIdsOriginal;

  /// UI’da geçici olarak değiştirilen yetki ID’leri
  final Set<int> menuIdsPending;

  const RoleMenuAuthentication({
    this.id,
    this.role,
    Set<int>? menuIdsOriginal,
    Set<int>? menuIdsPending,
  })  : menuIdsOriginal = menuIdsOriginal ?? const <int>{},
        menuIdsPending = menuIdsPending ?? const <int>{};

  /// Değişiklik var mı?
  bool get isDirty => menuIdsOriginal.length != menuIdsPending.length || !menuIdsOriginal.containsAll(menuIdsPending);

  /// Pending’i tamamen değiştir
  RoleMenuAuthentication withPending(Set<int> ids) => copyWith(menuIdsPending: {...ids});

  RoleMenuAuthentication toggle(int id) {
    final n = {...menuIdsPending};
    if (n.contains(id)) {
      n.remove(id);
    } else {
      n.add(id);
    }
    return copyWith(menuIdsPending: n);
  }

  /// İptal → pending’i orijinale sar
  RoleMenuAuthentication reset() => copyWith(menuIdsPending: {...menuIdsOriginal});

  /// Kaydet sonrası → orijinali pending ile eşitle
  RoleMenuAuthentication commit() => copyWith(menuIdsOriginal: {...menuIdsPending});

  RoleMenuAuthenticationDTO toDTO() {
    return RoleMenuAuthenticationDTO(
      id: id,
      roleId: role?.id,
      menuIds: menuIdsPending.toList(),
    );
  }

  RoleMenuAuthentication copyWith({
    int? id,
    Role? role,
    Set<int>? menuIdsOriginal,
    Set<int>? menuIdsPending,
  }) {
    return RoleMenuAuthentication(
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
