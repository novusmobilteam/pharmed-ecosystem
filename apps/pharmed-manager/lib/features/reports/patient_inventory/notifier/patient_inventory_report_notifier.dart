import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class PatientInventoryReportNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<PrescriptionItem> {
  final GetHospitalizationsUseCase _getHospitalizationsUseCase;
  final GetPatientInventoryUseCase _getPatientInventoryUseCase;

  PatientInventoryReportNotifier({
    required GetHospitalizationsUseCase getHospitalizationsUseCase,
    required GetPatientInventoryUseCase getPatientInventoryUseCase,
  }) : _getHospitalizationsUseCase = getHospitalizationsUseCase,
       _getPatientInventoryUseCase = getPatientInventoryUseCase;

  OperationKey fetchHospitalizationsOp = OperationKey.fetch();
  OperationKey fetchReportsOp = OperationKey.fetch();

  List<Hospitalization> _hospitalizations = [];
  List<Hospitalization> get hospitalizations => _hospitalizations;

  Hospitalization? _selectedHospitalization;
  Hospitalization? get selectedHospitalization => _selectedHospitalization;

  List<TableSideCategory> get tableCategories => [
    ..._hospitalizations.map((s) => TableSideCategory(id: s.id.toString(), label: s.patient?.fullName ?? '-')),
  ];

  String get selectedCategoryId => _selectedHospitalization?.id.toString() ?? '-1';
  int get activeIndex =>
      !_hospitalizations.contains(_selectedHospitalization) ? 0 : _hospitalizations.indexOf(_selectedHospitalization!);

  bool get isFetching => isLoading(fetchReportsOp);
  String? get statusMessage => message(fetchReportsOp);

  Future<void> getStations() async {
    await execute(
      fetchHospitalizationsOp,
      operation: () => _getHospitalizationsUseCase.call(PagedQueryParams()),
      onData: (response) {
        final data = response.data ?? [];
        _hospitalizations = data;
        if (data.isNotEmpty) {
          selectHospitalization(data.first);
        }
      },
    );
  }

  void selectHospitalization(Hospitalization hosp) {
    _selectedHospitalization = hosp;
    fetch();
    notifyListeners();
  }

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      op: fetchReportsOp,
      fetchMethod: (skip, take) => _getPatientInventoryUseCase.call(
        patientId: _selectedHospitalization?.patient?.id ?? 0,
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
      ),
    );
  }
}
