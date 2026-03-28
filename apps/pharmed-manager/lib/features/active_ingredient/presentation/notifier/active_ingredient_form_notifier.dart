import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

import '../../domain/entity/active_ingredient.dart';
import '../../domain/usecase/create_active_ingredient_usecase.dart';
import '../../domain/usecase/update_active_ingredient_usecase.dart';

class ActiveIngredientFormNotifier extends ChangeNotifier with ApiRequestMixin {
  ActiveIngredient _activeIngredient;
  final CreateActiveIngredientUseCase _createActiveIngredientUseCase;
  final UpdateActiveIngredientUseCase _updateActiveIngredientUseCase;

  ActiveIngredientFormNotifier({
    required CreateActiveIngredientUseCase createActiveIngredientUseCase,
    required UpdateActiveIngredientUseCase updateActiveIngredientUseCase,
    ActiveIngredient? activeIngredient,
  }) : _createActiveIngredientUseCase = createActiveIngredientUseCase,
       _updateActiveIngredientUseCase = updateActiveIngredientUseCase,
       _activeIngredient = activeIngredient ?? ActiveIngredient();

  OperationKey submitOp = OperationKey(OperationType.create);
  bool get isSubmitting => isLoading(submitOp);

  ActiveIngredient get activeIngredient => _activeIngredient;
  bool get isCreate => _activeIngredient.id == null;
  bool get isValid => _activeIngredient.isValid;
  String? get nameError => _activeIngredient.nameError;

  // Functions
  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    if (!isValid) return;

    await executeVoid(
      submitOp,
      operation: () => isCreate
          ? _createActiveIngredientUseCase.call(_activeIngredient)
          : _updateActiveIngredientUseCase.call(_activeIngredient),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı.'),
    );
  }

  void updateName(String? value) {
    _activeIngredient = _activeIngredient.updateName(value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _activeIngredient = _activeIngredient.updateStatus(value);
    notifyListeners();
  }
}
