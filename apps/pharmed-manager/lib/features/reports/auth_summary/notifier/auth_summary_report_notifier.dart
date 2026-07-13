import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class AuthSummaryReportNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<UserAuthorizationSummary> {
  final GetAuthorizationSummaryUseCase _getAuthorizationSummaryUseCase;
  final GetUserAuthorizationSummaryUseCase _getUserAuthorizationSummaryUseCase;

  AuthSummaryReportNotifier({
    required GetAuthorizationSummaryUseCase getAuthorizationSummaryUseCase,
    required GetUserAuthorizationSummaryUseCase getUserAuthorizationSummaryUseCase,
  }) : _getAuthorizationSummaryUseCase = getAuthorizationSummaryUseCase,
       _getUserAuthorizationSummaryUseCase = getUserAuthorizationSummaryUseCase;

  OperationKey fetchReportsOp = OperationKey.fetch();
  OperationKey fetchDetailOp = OperationKey.fetch();

  bool get isFetching => isLoading(fetchReportsOp);
  String? get statusMessage => message(fetchReportsOp);

  UserAuthorizationDetail? _userAuth;
  UserAuthorizationDetail? get userAuth => _userAuth;

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      op: fetchReportsOp,
      fetchMethod: (skip, take) => _getAuthorizationSummaryUseCase.call(
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
      ),
    );
  }

  Future<void> getUserSummary(int userId) async {
    await execute(
      fetchDetailOp,
      operation: () => _getUserAuthorizationSummaryUseCase.call(userId),
      onData: (data) {
        _userAuth = data;

        notifyListeners();
      },
    );
  }
}
