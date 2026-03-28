import 'package:flutter/widgets.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/role.dart';
import '../../domain/usecase/delete_role_usecase.dart';
import '../../domain/usecase/get_roles_usecase.dart';

class RoleTableNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Role> {
  final GetRolesUseCase _getRolesUseCase;
  final DeleteRoleUseCase _deleteRoleUseCase;

  RoleTableNotifier({required GetRolesUseCase getRolesUseCase, required DeleteRoleUseCase deleteRoleUseCase})
    : _getRolesUseCase = getRolesUseCase,
      _deleteRoleUseCase = deleteRoleUseCase;

  // Operation Keys
  OperationKey delete = OperationKey.delete();

  // Getters
  bool get isFetching => isTableLoading;
  bool get isDeleting => isLoading(delete);
  String? get statusMessage => message(delete);

  // Search
  String _searchQuery = '';

  // Functions
  Future<void> getRoles() async {
    await fetchPagedData(
      fetchMethod: (skip, take) => _getRolesUseCase.call(GetRolesParams(search: _searchQuery, skip: skip, take: take)),
    );
  }

  Future<void> deleteRole(Role role) async {
    await executeVoid(
      delete,
      operation: () => _deleteRoleUseCase.call(role),
      onSuccess: () => getRoles(),
      successMessage: 'Rol başarıyla silindi',
    );
  }

  void search(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    setPage(1);
    getRoles();
  }
}
