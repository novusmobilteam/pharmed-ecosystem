import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../../user/user.dart';

class UserTableNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<User> {
  final GetUsersUseCase _getUsersUseCase;

  UserTableNotifier({required GetUsersUseCase getUsersUseCase}) : _getUsersUseCase = getUsersUseCase;

  static const fetch = OperationKey.fetch();

  bool get isFetching => isTableLoading;

  String _searchQuery = '';

  Future<void> getUsers() async {
    await fetchPagedData(
      fetchMethod: (skip, take) async {
        return _getUsersUseCase.call(GetUsersParams(skip: skip, take: take, search: _searchQuery));
      },
    );
  }

  void search(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    // Sayfayı resetle ve veriyi tekrar çek
    setPage(1);
    getUsers();
  }
}
