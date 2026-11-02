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

  Prescription? _selectedPrescription;
  Prescription? get selectedPrescription => _selectedPrescription;

  Map<int, List<PrescriptionItem>> get groupedPrescriptions => _prescriptionItems.groupedById;

  bool _isPanelOpen = false;
  bool get isPanelOpen => _isPanelOpen;

  /// true → ekranda geciken uygulamalar tablosu gösterilir. O tablonun verisi
  /// reçete kalemi olduğundan ayrı notifier'dadır (OverdueApplicationsNotifier).
  bool _showOverdue = false;
  bool get showOverdue => _showOverdue;

  void openPanel(Prescription item) {
    _selectedPrescription = item;
    _isPanelOpen = true;
    _getUnappliedPrescriptionDetail();
    notifyListeners();
  }

  void closePanel() {
    _isPanelOpen = false;
    _selectedPrescription = null;
    notifyListeners();
  }

  void toggleOverdue() {
    _showOverdue = !_showOverdue;
    if (_showOverdue) {
      _isPanelOpen = false;
      _selectedPrescription = null;
    }
    resetFilters(notify: false, resetDate: false);
    notifyListeners();
    if (!_showOverdue) fetch();
  }

  @override
  Future<void> fetch() async {
    if (_showOverdue) return;
    await _fetchAllPrescriptions();
  }

  Future<void> _fetchAllPrescriptions() async {
    await fetchPagedData(
      fetchMethod: (skip, take) => _getUnappliedPrescriptionsUseCase.call(
        params: PagedQueryParams(
          skip: skip,
          take: take,
          searchQuery: searchQuery,
          startDate: startDate,
          endDate: endDate,
        ),
      ),
    );
  }

  Future<void> _getUnappliedPrescriptionDetail() async {
    final prescriptionId = _selectedPrescription?.id;
    if (prescriptionId == null) return;

    await execute(
      fetchDetailOp,
      operation: () => _getUnappliedPrescriptionDetailUseCase.call(prescriptionId),
      onData: (data) {
        _prescriptionItems = data;
      },
    );
  }
}
