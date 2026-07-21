import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class KitNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Kit> {
  final GetKitsUseCase _getKitsUseCase;
  final DeleteKitUseCase _deleteKitUseCase;

  KitNotifier({required GetKitsUseCase getKitsUseCase, required DeleteKitUseCase deleteKitUseCase})
    : _deleteKitUseCase = deleteKitUseCase,
      _getKitsUseCase = getKitsUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();

  bool get isFetching => isLoading(fetchOp);

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      op: fetchOp,
      fetchMethod: (skip, take) =>
          _getKitsUseCase.call(PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery)),
    );
  }

  Future<void> deleteKit(Kit kit, {Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteKitUseCase.call(kit),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call(null);
        fetch();
      },
    );
  }
}
