import 'package:flutter/widgets.dart';

import 'package:pharmed_manager/core/core.dart';

/// Uygulanmamış Reçeteler (`Prescription/uncollectedPrescriptionMaster`).
///
/// Her satır bir yatıştır; yatışın bekleyen reçete kalemleri listeyle birlikte
/// geldiği için detay paneli ayrı servis çağırmadan satırdaki kalemleri gösterir.
class UnappliedPrescriptionsNotifier extends ChangeNotifier
    with ApiRequestMixin, PaginationMixin<UnappliedHospitalization> {
  final GetUnappliedPrescriptionsUseCase _getUnappliedPrescriptionsUseCase;

  UnappliedPrescriptionsNotifier({required GetUnappliedPrescriptionsUseCase getUnappliedPrescriptionsUseCase})
    : _getUnappliedPrescriptionsUseCase = getUnappliedPrescriptionsUseCase;

  OperationKey fetchOp = OperationKey.fetch();

  bool get isFetching => isLoading(fetchOp);

  UnappliedHospitalization? _selectedHospitalization;
  UnappliedHospitalization? get selectedHospitalization => _selectedHospitalization;

  /// Seçili yatışın bekleyen reçete kalemleri.
  List<PrescriptionItem> get prescriptionItems => _selectedHospitalization?.items ?? const [];

  /// Kalemler gün bazında (detay panelinde `RxGroupCard.day` kartları) —
  /// reçete işlemleri paneliyle aynı gruplama.
  List<({DateTime? day, List<PrescriptionItem> items})> get dayGroups => prescriptionItems.groupedByDay;

  bool _isPanelOpen = false;
  bool get isPanelOpen => _isPanelOpen;

  /// true → ekranda geciken uygulamalar tablosu gösterilir. O tablonun verisi
  /// reçete kalemi olduğundan ayrı notifier'dadır (OverdueApplicationsNotifier).
  bool _showOverdue = false;
  bool get showOverdue => _showOverdue;

  void openPanel(UnappliedHospitalization item) {
    _selectedHospitalization = item;
    _isPanelOpen = true;
    notifyListeners();
  }

  void closePanel() {
    _isPanelOpen = false;
    _selectedHospitalization = null;
    notifyListeners();
  }

  void toggleOverdue() {
    _showOverdue = !_showOverdue;
    if (_showOverdue) {
      _isPanelOpen = false;
      _selectedHospitalization = null;
    }
    resetFilters(notify: false, resetDate: false);
    notifyListeners();
    if (!_showOverdue) fetch();
  }

  @override
  Future<void> fetch() async {
    if (_showOverdue) return;
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
    _syncSelection();
  }

  /// Liste yenilendiğinde açık paneldeki yatışı yeni veriyle değiştirir;
  /// yatış artık listede yoksa (tüm kalemleri uygulanmış) paneli kapatır.
  void _syncSelection() {
    final selectedId = _selectedHospitalization?.hospitalizationId;
    if (selectedId == null) return;
    final fresh = items.where((e) => e.hospitalizationId == selectedId).firstOrNull;
    if (fresh == null) {
      closePanel();
    } else {
      _selectedHospitalization = fresh;
      notifyListeners();
    }
  }
}
