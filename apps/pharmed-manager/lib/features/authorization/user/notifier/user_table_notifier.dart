import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class UserTableNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<User> {
  final GetUsersUseCase _getUsersUseCase;

  UserTableNotifier({required GetUsersUseCase getUsersUseCase}) : _getUsersUseCase = getUsersUseCase;

  static const fetchOp = OperationKey.fetch();

  bool get isFetching => isTableLoading;

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      fetchMethod: (skip, take) async {
        return _getUsersUseCase.call(GetUsersParams(skip: skip, take: take, search: searchQuery));
      },
    );
  }
}
