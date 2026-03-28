import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/active_ingredient.dart';
import '../../domain/usecase/delete_active_ingredient_usecase.dart';
import '../../domain/usecase/get_active_ingredients_usecase.dart';

class ActiveIngredientNotifier extends ChangeNotifier with SearchMixin<ActiveIngredient>, ApiRequestMixin {
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

  // Functions
  Future<void> getActiveIngredients() async {
    await execute(
      fetchOp,
      operation: () => _getActiveIngredientsUseCase.call(GetActiveIngredientsParams()),
      onData: (response) => allItems = response.data ?? [],
    );
  }

  Future<void> deleteActiveIngredient(
    int id, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    final item = allItems.firstWhere((x) => x.id == id);

    await executeVoid(
      deleteOp,
      operation: () => _deleteActiveIngredientUseCase.call(item),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı.');
        getActiveIngredients();
      },
    );
  }
}
