import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class FirmNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Firm> {
  final GetFirmsUseCase _getFirmsUseCase;
  final DeleteFirmUseCase _deleteFirmUseCase;

  FirmNotifier({required GetFirmsUseCase getFirmsUseCase, required DeleteFirmUseCase deleteFirmUseCase})
    : _getFirmsUseCase = getFirmsUseCase,
      _deleteFirmUseCase = deleteFirmUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();

  bool get isDeleting => isLoading(deleteOp);

  Firm? _selectedFirm;
  Firm? get selectedFirm => _selectedFirm;

  bool _isPanelOpen = false;
  bool get isPanelOpen => _isPanelOpen;

  void openPanel({Firm? firm}) {
    _selectedFirm = firm;
    _isPanelOpen = true;
    notifyListeners();
  }

  void closePanel() {
    _isPanelOpen = false;
    _selectedFirm = null;
    notifyListeners();
  }

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      fetchMethod: (skip, take) => _getFirmsUseCase.call(
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
      ),
    );
  }

  Future<void> deleteFirm(Firm firm, {Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteFirmUseCase.call(firm),
      onSuccess: () {
        onSuccess?.call(contextlessL10n().common_operationSuccessMessage);
        fetch();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
