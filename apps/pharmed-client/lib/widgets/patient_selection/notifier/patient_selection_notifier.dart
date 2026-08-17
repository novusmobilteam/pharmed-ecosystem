import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../core/mixins/api_request_mixin.dart';
import '../../../features/auth/auth.dart';

class PatientSelectionConfig {
  const PatientSelectionConfig({
    this.showIntakeTabs = false,
    this.showViewTypeSelector = false,
    this.showOrderStatusToggle = false,
    this.showFilterRow = false,
  });

  /// prescriptions/redirected tab seçici — sadece intake'te.
  final bool showIntakeTabs;

  /// allPatients/myPatients seçici — sadece intake'te.
  final bool showViewTypeSelector;

  /// ordered/orderless toggle — sadece intake'te (ve zaten mevcut
  /// station/user yetkisi şartlarıyla birlikte).
  final bool showOrderStatusToggle;

  /// PatientFilterType satırı — sadece intake'te.
  final bool showFilterRow;

  /// Hiçbiri açık değilse ekran "genel/basit" modda demektir — bu durumda
  /// _fetchPatients tab/filtre ayrımı yapmadan doğrudan aktif yatışları çeker.
  bool get isSimpleMode => !showIntakeTabs && !showViewTypeSelector && !showOrderStatusToggle && !showFilterRow;
}

enum IntakePatientTab { prescriptions, redirected }

enum PatientViewType { allPatients, myPatients }

extension IntakePatientTabX on IntakePatientTab {
  String label(BuildContext context) {
    switch (this) {
      case IntakePatientTab.prescriptions:
        return context.l10n.intake_tab_prescriptions;
      case IntakePatientTab.redirected:
        return context.l10n.intake_tab_redirectedOrders;
    }
  }
}

extension PatientViewTypeX on PatientViewType {
  String label(BuildContext context) {
    switch (this) {
      case PatientViewType.allPatients:
        return context.l10n.enumCore_patientFilterAll;
      case PatientViewType.myPatients:
        return context.l10n.patientPicker_myPatientsToggleLabel;
    }
  }
}

class PatientSelectionNotifier extends ChangeNotifier with ApiRequestMixin {
  final PatientSelectionConfig config;
  final AuthNotifier _authNotifier;
  final GetCurrentStationUseCase _getStation;
  final GetHospitalizationsByServiceUseCase _getHospitalizations;
  final GetActiveHospitalizationsUseCase _getActiveHospitalizations;
  final CreateUrgentPatientUseCase _createUrgent;
  final GetServicesUseCase _getServices;

  PatientSelectionNotifier({
    required this.config,
    required AuthNotifier authNotifier,
    required GetCurrentStationUseCase getStation,
    required GetHospitalizationsByServiceUseCase getHospitalizations,
    required GetActiveHospitalizationsUseCase getActiveHospitalizations,
    required CreateUrgentPatientUseCase createUrgent,
    required GetServicesUseCase getServices,
  }) : _authNotifier = authNotifier,
       _getStation = getStation,
       _getHospitalizations = getHospitalizations,
       _getActiveHospitalizations = getActiveHospitalizations,
       _createUrgent = createUrgent,
       _getServices = getServices;

  final OperationKey fetchStationOp = OperationKey.custom('fetch-station');
  bool get isFetchingStations => isLoading(fetchStationOp);

  final OperationKey fetchHospOp = OperationKey.custom('fetch-hosp');
  bool get isFetchingHospitalizations => isLoading(fetchStationOp);

  final OperationKey fetchActiveHospOp = OperationKey.custom('fetch-active-hosp');

  final OperationKey createUrgentOp = OperationKey.custom('create-urgent');
  bool get isCreatingUrgent => isLoading(createUrgentOp);

  final OperationKey fetchServicesOp = OperationKey.custom('fetch-services');
  bool get isFetchingServices => isLoading(fetchServicesOp);

  IntakePatientTab _intakeTab = IntakePatientTab.prescriptions;
  IntakePatientTab get intakeTab => _intakeTab;

  PatientViewType _viewType = PatientViewType.allPatients;
  PatientViewType get viewType => _viewType;

  OrderStatus _orderStatus = OrderStatus.ordered;
  OrderStatus get orderStatus => _orderStatus;

  PatientFilterType _filterType = PatientFilterType.ordersDue;
  PatientFilterType get filterType => _filterType;

  Station? _activeStation;
  Station? get activeStation => _activeStation;

  List<Hospitalization> _hospitalizations = [];
  List<Hospitalization> get hospitalizations => _hospitalizations;

  Hospitalization? _selected;
  Hospitalization? get selected => _selected;

  Hospitalization? _urgentPatient;
  Hospitalization? get urgentPatient => _urgentPatient;

  List<HospitalService> _services = [];
  List<HospitalService> get services => _services;

  AppUser? get activeUser => _authNotifier.currentUser;

  OrderStatus get stationOrderStatus => _activeStation?.drugStatus ?? OrderStatus.ordered;
  OrderStatus get userOrderStatus => orderStatusFromBool(activeUser?.isNotOrdered ?? false);

  bool get showOrderToggleButton =>
      config.showOrderStatusToggle &&
      (!stationOrderStatus.isOrderless && userOrderStatus.isOrderless) &&
      _intakeTab == IntakePatientTab.prescriptions;

  bool get showFilterRow =>
      config.showFilterRow &&
      _intakeTab == IntakePatientTab.prescriptions &&
      _viewType == PatientViewType.allPatients &&
      _orderStatus == OrderStatus.ordered;

  bool get hasUrgentPatient => _urgentPatient != null;
  bool _isCreateSheetOpen = false;
  bool get isCreateSheetOpen => _isCreateSheetOpen;

  void changeIntakeTab(IntakePatientTab tab) {
    if (hasUrgentPatient) return;
    _intakeTab = tab;
    _fetchPatients();
    notifyListeners();
  }

  void changeViewType(PatientViewType type) {
    if (hasUrgentPatient) return;
    _viewType = type;
    _fetchPatients();
    notifyListeners();
  }

  void toggleOrderStatus() {
    if (hasUrgentPatient) return;
    _orderStatus == OrderStatus.ordered ? _orderStatus = OrderStatus.orderless : _orderStatus = OrderStatus.ordered;
    _fetchPatients();
    notifyListeners();
  }

  void changeFilterType(PatientFilterType type) {
    if (hasUrgentPatient) return;
    _filterType = type;
    _fetchPatients();
    notifyListeners();
  }

  Future<void> init() async {
    await Future.wait([_fetchStation(), _fetchPatients()]);
  }

  Future<void> _fetchStation() async {
    if (_activeStation != null) return;
    await execute(
      fetchStationOp,
      operation: () => _getStation.call(),
      onData: (station) {
        _activeStation = station;
        notifyListeners();
      },
    );
  }

  Future<void> fetchServices({required Function(String msg) onError, required VoidCallback onSuccess}) async {
    if (_services.isNotEmpty) {
      onSuccess.call();
      return;
    }
    await execute(
      fetchServicesOp,
      operation: () => _getServices.call(PagedQueryParams()),
      onData: (response) {
        _services = response.data ?? [];
        onSuccess.call();
        notifyListeners();
      },
      onFailed: (error) => onError(error.message),
    );
  }

  Future<void> _fetchPatients() async {
    if (config.isSimpleMode) {
      await execute(
        fetchHospOp,
        operation: () => _getActiveHospitalizations.call(const PagedQueryParams()),
        onData: (response) {
          _hospitalizations = response.data ?? [];
          notifyListeners();
        },
        onFailed: (_) {
          _hospitalizations = [];
        },
      );
      return;
    }

    final tab = _intakeTab;
    final params = PagedQueryParams();

    Future<Result<ApiResponse<List<Hospitalization>>>> Function() operation;
    switch (tab) {
      case IntakePatientTab.prescriptions:
        operation = () => _getHospitalizations.call(
          params,
          serviceId: 0,
          filter: orderStatus.isOrderless ? PatientFilterType.all : _filterType,
          myPatients: _viewType == PatientViewType.myPatients,
        );
      case IntakePatientTab.redirected:
        operation = _viewType == PatientViewType.myPatients
            ? () => _getHospitalizations.call(params, serviceId: 0, filter: PatientFilterType.all, myPatients: true)
            : () => _getActiveHospitalizations.call(const PagedQueryParams());
    }

    await execute(
      fetchHospOp,
      operation: operation,
      onData: (response) {
        _hospitalizations = response.data ?? [];
        notifyListeners();
      },
      onFailed: (_) {
        _hospitalizations = [];
      },
    );
  }

  void onPatientTap(Hospitalization hosp) {
    _selected = hosp;
    notifyListeners();
  }

  Future<void> createUrgentPatient({
    required int serviceId,
    required ValueChanged<Hospitalization> onCreated,
    required ValueChanged<String> onFailed,
  }) async {
    await execute(
      createUrgentOp,
      operation: () => _createUrgent.call(serviceId),
      onData: (hosp) {
        _urgentPatient = hosp;
        _isCreateSheetOpen = false;
        notifyListeners();
      },
    );
  }

  /// Kullanıcı acil hastayı kaldırdığında panel varsayılan (liste) haline döner.
  void clearUrgentPatient() {
    if (_urgentPatient == null) return;
    if (_selected == _urgentPatient) _selected = null;
    _urgentPatient = null;
    _fetchPatients();
    notifyListeners();
  }

  void openCreateSheet() {
    if (_isCreateSheetOpen) return;
    _isCreateSheetOpen = true;
    notifyListeners();
  }

  void closeCreateSheet() {
    if (!_isCreateSheetOpen) return;
    _isCreateSheetOpen = false;
    notifyListeners();
  }
}
