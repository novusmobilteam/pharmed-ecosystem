import 'package:flutter/widgets.dart';

import 'package:pharmed_manager/core/core.dart';

class UnappliedPrescriptionsNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Prescription> {
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
  Future<void> fetch() async {
    await fetchPagedData(
      fetchMethod: (skip, take) => _getUnappliedPrescriptionsUseCase.call(
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
      ),
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
