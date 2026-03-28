import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/drug_class.dart';
import '../../domain/usecase/delete_drug_class_usecase.dart';
import '../../domain/usecase/get_drug_classes_usecase.dart';

class DrugClassNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<DrugClass> {
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

  Future<void> getDrugClasses() async {
    await execute(
      fetchOp,
      operation: () => _getDrugClassUseCase.call(GetDrugClassParams()),
      onData: (response) => allItems = response.data ?? [],
    );
  }

  Future<void> deleteDrugClass(int id, {Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    final item = allItems.firstWhere((x) => x.id == id, orElse: () => DrugClass(id: id));

    await executeVoid(
      deleteOp,
      operation: () => _deleteDrugClassUseCase.call(item),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı');
        getDrugClasses();
      },
    );
  }
}
