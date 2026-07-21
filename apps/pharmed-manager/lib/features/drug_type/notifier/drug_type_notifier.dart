import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

/// İlaç tipi listesi ViewModel'i.
class DrugTypeNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<DrugType> {
  final GetDrugTypesUseCase _getDrugTypesUseCase;
  final DeleteDrugTypeUseCase _deleteDrugTypeUseCase;

  DrugTypeNotifier({
    required GetDrugTypesUseCase getDrugTypesUseCase,
    required DeleteDrugTypeUseCase deleteDrugTypeUseCase,
  }) : _getDrugTypesUseCase = getDrugTypesUseCase,
       _deleteDrugTypeUseCase = deleteDrugTypeUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();

  bool get isFetching => isLoading(fetchOp);

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      op: fetchOp,
      fetchMethod: (skip, take) =>
          _getDrugTypesUseCase.call(PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery)),
    );
  }

  Future<void> deleteDrugType(
    DrugType type, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteDrugTypeUseCase.call(type),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call(null);
        fetch();
      },
    );
  }
}
