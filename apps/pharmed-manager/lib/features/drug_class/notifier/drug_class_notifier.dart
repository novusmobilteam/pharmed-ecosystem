import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class DrugClassNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<DrugClass> {
  final GetDrugClassUseCase _getDrugClassUseCase;
  final DeleteDrugClassUseCase _deleteDrugClassUseCase;

  DrugClassNotifier({
    required GetDrugClassUseCase getDrugClassUseCase,
    required DeleteDrugClassUseCase deleteDrugClassUseCase,
  }) : _getDrugClassUseCase = getDrugClassUseCase,
       _deleteDrugClassUseCase = deleteDrugClassUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();

  bool get isFetching => isLoading(fetchOp);

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      fetchMethod: (skip, take) =>
          _getDrugClassUseCase.call(PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery)),
    );
  }

  Future<void> deleteDrugClass(int id, {Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    final item = items.firstWhere((x) => x.id == id, orElse: () => DrugClass(id: id));

    await executeVoid(
      deleteOp,
      operation: () => _deleteDrugClassUseCase.call(item),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call(null);
        fetch();
      },
    );
  }
}
