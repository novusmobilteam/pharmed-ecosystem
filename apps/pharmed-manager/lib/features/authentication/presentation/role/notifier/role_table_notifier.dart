import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class RoleTableNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Role> {
  final GetRolesUseCase _getRolesUseCase;

  RoleTableNotifier({required GetRolesUseCase getRolesUseCase}) : _getRolesUseCase = getRolesUseCase;

  OperationKey fetchOp = OperationKey.fetch();

  bool get isFetching => isTableLoading;

  String _searchQuery = '';

  Future<void> getRoles() async {
    await fetchPagedData(
      fetchMethod: (int skip, int take) async {
        return _getRolesUseCase.call(GetRolesParams(search: _searchQuery, skip: skip, take: take));
      },
    );
  }

  void search(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    setPage(1);
    getRoles();
  }
}
