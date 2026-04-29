import 'package:flutter/widgets.dart';

import 'package:pharmed_manager/core/core.dart';

class UnappliedPrescriptionsNotifier extends ChangeNotifier
    with ApiRequestMixin, SearchMixin<Prescription>, DateFilterMixin<Prescription> {
  final GetUnappliedPrescriptionsUseCase _getUnappliedPrescriptionsUseCase;
  final GetUnappliedPrescriptionDetailUseCase _getUnappliedPrescriptionDetailUseCase;

  UnappliedPrescriptionsNotifier({
    required GetUnappliedPrescriptionsUseCase getUnappliedPrescriptionsUseCase,
    required GetUnappliedPrescriptionDetailUseCase getUnappliedPrescriptionDetailUseCase,
  }) : _getUnappliedPrescriptionsUseCase = getUnappliedPrescriptionsUseCase,
       _getUnappliedPrescriptionDetailUseCase = getUnappliedPrescriptionDetailUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey fetchDetailOp = OperationKey.custom('fetch-detail');

  bool get isFetching => isLoading(fetchOp);
  bool get isFetchingDetail => isLoading(fetchDetailOp);

  List<PrescriptionItem> _prescriptionItems = [];
  List<PrescriptionItem> get prescriptionItems => _prescriptionItems;

  @override
  DateTime? getDateField(Prescription item) => item.hospitalizationDate;

  @override
  List<Prescription> get filteredItems {
    if (super.searchQuery.isNotEmpty) {
      return super.filteredItems;
    }
    return applyDateFilter(allItems);
  }

  Future<void> getUnappliedPrescriptions() async {
    await execute(
      fetchOp,
      operation: () => _getUnappliedPrescriptionsUseCase.call(),
      onData: (apiResponse) {
        allItems = apiResponse?.data ?? [];
      },
    );
  }

  Future<void> getUnappliedPrescriptionDetail(int prescriptionId) async {
    await execute(
      fetchOp,
      operation: () => _getUnappliedPrescriptionDetailUseCase.call(prescriptionId),
      onData: (data) {
        _prescriptionItems = data;
      },
    );
  }
}
