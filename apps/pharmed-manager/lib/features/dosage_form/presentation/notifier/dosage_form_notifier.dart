import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/dosage_form.dart';
import '../../domain/usecase/delete_dosage_form_usecase.dart';
import '../../domain/usecase/get_dosage_forms_usecase.dart';

class DosageFormNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<DosageForm> {
  final GetDosageFormsUseCase _getDosageFormsUseCase;
  final DeleteDosageFormUseCase _deleteDosageFormUseCase;

  DosageFormNotifier({
    required GetDosageFormsUseCase getDosageFormsUseCase,
    required DeleteDosageFormUseCase deleteDosageFormUseCase,
  }) : _getDosageFormsUseCase = getDosageFormsUseCase,
       _deleteDosageFormUseCase = deleteDosageFormUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();

  bool get isFetching => isLoading(fetchOp);
  bool get isDeleting => isLoading(deleteOp);
  String? get statusMessage => message(fetchOp) ?? message(deleteOp);

  Future<void> getDosageForms({bool forceRefresh = false}) async {
    await execute(
      fetchOp,
      operation: () => _getDosageFormsUseCase.call(GetDosageFormParams()),
      onData: (response) => allItems = response.data ?? [],
    );
  }

  Future<void> deleteDosageForm(
    int id, {
    Function(String? message)? onSuccess,
    Function(String? message)? onFailed,
  }) async {
    final item = allItems.firstWhere((x) => x.id == id);

    await executeVoid(
      deleteOp,
      operation: () => _deleteDosageFormUseCase.call(item),
      onSuccess: () {
        onSuccess?.call('Dozaj formu silme işlemi başarılı.');
        getDosageForms();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
