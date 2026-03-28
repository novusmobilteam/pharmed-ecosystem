import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/drug_type.dart';
import '../../domain/usecase/delete_drug_type_usecase.dart';
import '../../domain/usecase/get_drug_types_usecase.dart';

/// İlaç tipi listesi ViewModel'i.
class DrugTypeNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<DrugType> {
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

  // Functions
  Future<void> getDrugTypes() async {
    await execute(
      fetchOp,
      operation: () => _getDrugTypesUseCase.call(GetDrugTypesParams()),
      onData: (response) => allItems = response.data ?? [],
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
        onSuccess?.call('İşleminiz başarıyla tamamlandı.');
        getDrugTypes();
      },
    );
  }
}
