import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class DosageFormNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<DosageForm> {
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

  @override
  Future<void> fetch({bool forceRefresh = false}) async {
    await fetchPagedData(
      op: fetchOp,
      fetchMethod: (skip, take) =>
          _getDosageFormsUseCase.call(PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery)),
    );
  }

  Future<void> deleteDosageForm(
    int id, {
    Function(String? message)? onSuccess,
    Function(String? message)? onFailed,
  }) async {
    final item = items.firstWhere((x) => x.id == id);

    await executeVoid(
      deleteOp,
      operation: () => _deleteDosageFormUseCase.call(item),
      onSuccess: () {
        onSuccess?.call(contextlessL10n().dosageForm_deleteSuccessMessage);
        fetch();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
