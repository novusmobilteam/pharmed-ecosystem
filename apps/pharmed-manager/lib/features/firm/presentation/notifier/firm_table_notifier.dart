import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/firm.dart';
import '../../domain/usecase/delete_firm_usecase.dart';
import '../../domain/usecase/get_firms_usecase.dart';

class FirmTableNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<Firm> {
  final GetFirmsUseCase _getFirmsUseCase;
  final DeleteFirmUseCase _deleteFirmUseCase;

  FirmTableNotifier({required GetFirmsUseCase getFirmsUseCase, required DeleteFirmUseCase deleteFirmUseCase})
    : _getFirmsUseCase = getFirmsUseCase,
      _deleteFirmUseCase = deleteFirmUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();

  bool get isDeleting => isLoading(deleteOp);

  Future<void> getFirms() async {
    await execute(
      fetchOp,
      operation: () => _getFirmsUseCase.call(GetFirmsParams()),
      onData: (response) {
        if (response.data != null) {
          allItems = response.data!;
        }
      },
    );
  }

  Future<void> deleteFirm(int id, {Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteFirmUseCase.call(DeleteFirmParams(id)),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı');
        getFirms();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
