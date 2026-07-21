import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class ActiveIngredientNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<ActiveIngredient> {
  final GetActiveIngredientsUseCase _getActiveIngredientsUseCase;
  final DeleteActiveIngredientUseCase _deleteActiveIngredientUseCase;

  ActiveIngredientNotifier({
    required GetActiveIngredientsUseCase getActiveIngredientsUseCase,
    required DeleteActiveIngredientUseCase deleteActiveIngredientUseCase,
  }) : _getActiveIngredientsUseCase = getActiveIngredientsUseCase,
       _deleteActiveIngredientUseCase = deleteActiveIngredientUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();

  // Getters
  bool get isFetching => isLoading(fetchOp);
  bool get isDeleting => isLoading(deleteOp);

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      fetchMethod: (skip, take) =>
          _getActiveIngredientsUseCase.call(PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery)),
    );
  }

  Future<void> deleteActiveIngredient(
    int id, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    final item = items.firstWhere((x) => x.id == id);

    await executeVoid(
      deleteOp,
      operation: () => _deleteActiveIngredientUseCase.call(item),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call(null);
        fetch();
      },
    );
  }
}
