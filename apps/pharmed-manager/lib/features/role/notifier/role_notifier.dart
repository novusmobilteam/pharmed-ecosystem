import 'package:flutter/widgets.dart';
import 'package:pharmed_manager/core/core.dart';

class RoleNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Role>, SidePanelMixin<Role, Never> {
  final GetRolesUseCase _getRolesUseCase;
  final DeleteRoleUseCase _deleteRoleUseCase;

  RoleNotifier({required GetRolesUseCase getRolesUseCase, required DeleteRoleUseCase deleteRoleUseCase})
    : _getRolesUseCase = getRolesUseCase,
      _deleteRoleUseCase = deleteRoleUseCase;

  OperationKey delete = OperationKey.delete();

  bool get isFetching => isTableLoading;
  bool get isDeleting => isLoading(delete);
  String? get statusMessage => message(delete);

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      fetchMethod: (skip, take) => _getRolesUseCase.call(GetRolesParams(search: searchQuery, skip: skip, take: take)),
    );
  }

  Future<void> deleteRole(Role role, {String? successMessage}) async {
    await executeVoid(
      delete,
      operation: () => _deleteRoleUseCase.call(role),
      onSuccess: () => fetch(),
      successMessage: successMessage,
    );
  }
}
