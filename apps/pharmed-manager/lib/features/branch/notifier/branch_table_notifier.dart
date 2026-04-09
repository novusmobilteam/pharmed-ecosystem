import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class BranchTableNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Branch> {
  final GetBranchesUseCase _getBranchesUseCase;
  final DeleteBranchUseCase _deleteBranchUseCase;

  BranchTableNotifier({
    required GetBranchesUseCase getBranchesUseCase,
    required DeleteBranchUseCase deleteBranchUseCase,
  }) : _getBranchesUseCase = getBranchesUseCase,
       _deleteBranchUseCase = deleteBranchUseCase;

  OperationKey deleteOp = OperationKey.delete();

  String _searchQuery = '';

  bool get isFetching => isTableLoading;
  bool get isDeleting => isLoading(deleteOp);

  String? get statusMessage => message(deleteOp);

  Future<void> getBranches() async {
    await fetchPagedData(
      fetchMethod: (skip, take) {
        return _getBranchesUseCase.call(GetBranchesParams(skip: skip, take: take, search: _searchQuery));
      },
    );
  }

  Future<void> deleteBranch(Branch branch) async {
    await executeVoid(deleteOp, operation: () => _deleteBranchUseCase.call(branch), onSuccess: () => getBranches());
  }

  void search(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    setPage(1);
    getBranches();
  }
}
