import 'package:flutter/material.dart';

import '../../../../core/core.dart';

import '../../../auth/presentation/notifier/auth_notifier.dart';

enum MedicineManagementType { allPatients, myPatients }

class MedicineManagementNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<Hospitalization> {
  final GetCurrentStationUseCase _getCurrentStationUseCase;
  final CreateUrgentPatientUseCase _createUrgentPatientUseCase;
  final GetHospitalizationsByServiceUseCase _getHospitalizationsUseCase;
  final GetFilteredHospitalizationsUseCase _filteredHospitalizationsUseCase;
  final GetMyPatientsUseCase _getMyPatientsUseCase;

  MedicineManagementNotifier({
    required AuthNotifier authPersistence,
    required GetCurrentStationUseCase getCurrentStationUseCase,
    required GetHospitalizationsByServiceUseCase getHospitalizationsUseCase,
    required GetFilteredHospitalizationsUseCase filteredHospitalizationsUseCase,
    required CreateUrgentPatientUseCase createUrgentPatientUseCase,
    required GetMyPatientsUseCase getMyPatientsUseCase,
  }) : _getCurrentStationUseCase = getCurrentStationUseCase,
       _getHospitalizationsUseCase = getHospitalizationsUseCase,
       _filteredHospitalizationsUseCase = filteredHospitalizationsUseCase,
       _createUrgentPatientUseCase = createUrgentPatientUseCase,
       _getMyPatientsUseCase = getMyPatientsUseCase;

  OperationKey initOp = OperationKey.custom('init');
  OperationKey fetchOp = OperationKey.fetch();
  OperationKey urgentOp = OperationKey.create();
  OperationKey fetchMyPatientsOp = OperationKey.custom('fetch-my-patients');

  Station? _station;
  Station? get station => _station;

  HospitalService? _selectedService;
  HospitalService? get selectedService => _selectedService;

  /// Aktif kullanıcının orderlı işlem yapma durumu
  /// orderless -> Ordersız işlem yapabilir
  /// ordered -> Ordersız işlem yapamaz
  // OrderStatus get userOrderStatus => _authPersistence.orderStatus;
  OrderStatus get userOrderStatus => OrderStatus.ordered;

  /// Aktif istasyonun orderlı işlem yapma durumu
  /// true -> Ordersız işlem yapabilir
  /// false -> Ordersız işlem yapamaz
  OrderStatus get stationOrderStatus => _station?.drugStatus ?? OrderStatus.ordered;

  /// İstasyon ordersız ise sadece ordersız işlem yapılacak
  /// İstasyon orderlı ise ve kullanıcı ordersız işlem yapabiliyorsa orderlı ordersız arasında
  /// değişim yapabilecek
  OrderStatus _viewOrderStatus = OrderStatus.ordered;
  OrderStatus get viewOrderStatus => _viewOrderStatus;

  /// Toggle butonu görünürlüğü:
  /// İstasyon orderlı VE kullanıcı ordersız yetkisine sahipse görünsün.
  /// İstasyon ordersız ise ekran zaten ordersız modda sabit kalır, toggle gizlenir.
  bool get isStatusButtonVisible => stationOrderStatus.isOrdered && userOrderStatus.isOrderless;

  /// Acil Hasta Oluştur butonu görünürlüğü:
  /// Kullanıcı o an ordersız modda işlem yapabiliyorsa aktif olacak.
  /// - İstasyon ordersız → zaten ordersız modda, buton görünür
  /// - İstasyon orderlı + kullanıcı ordersız yetkisi var + ordersız moda geçtiyse görünür
  bool get isUrgentPatientButtonVisible => _viewOrderStatus.isOrderless;

  List<HospitalService> get availableServices => _station?.services ?? [];

  // Filter
  PatientFilterType _filterType = PatientFilterType.ordersDue;
  PatientFilterType get filter => _filterType;

  // Acil Hasta Oluştur butonu ile oluşturalan acil hasta
  Hospitalization? _urgentPatient;
  Hospitalization? get urgentPatient => _urgentPatient;

  // Kullanıcıya tanımlanmış hastalar
  List<Hospitalization> _myPatients = [];
  List<Hospitalization> get myPatients => _myPatients;

  MedicineManagementType managementType = MedicineManagementType.allPatients;

  void initialize() async {
    await execute(
      initOp,
      operation: () => _getCurrentStationUseCase.call(),
      onData: (data) {
        _station = data;

        // İstasyon ordersız → ekran ordersız modda sabit
        // İstasyon orderlı → orderlı modda başlar, kullanıcı yetkisi varsa toggle edebilir
        _viewOrderStatus = stationOrderStatus.isOrderless
            ? OrderStatus.orderless
            : userOrderStatus.isOrderless
            ? OrderStatus
                  .orderless // İstasyon orderlı ama kullanıcı ordersız yetkisi varsa ordersız başla
            : OrderStatus.ordered;

        if (_viewOrderStatus.isOrderless && availableServices.isNotEmpty) {
          _selectedService = availableServices.first;
        }

        getHospitalizations();
      },
    );
  }

  Future<void> getHospitalizations() async {
    viewOrderStatus.isOrderless ? _fetchHospitalizations() : _fetchFilteredHospitalizations();
  }

  Future<void> _fetchHospitalizations() async {
    if (_selectedService == null) return;
    int serviceId = _selectedService!.id ?? 0;
    await execute(
      fetchOp,
      operation: () => _getHospitalizationsUseCase.call(serviceId),
      onData: (data) {
        allItems = data.where((d) => !d.isUrgent).toList();
        notifyListeners();
      },
    );
  }

  Future<void> _fetchFilteredHospitalizations() async {
    await execute(
      fetchOp,
      operation: () => _filteredHospitalizationsUseCase.call(filter),
      onData: (data) {
        allItems = data;
        notifyListeners();
      },
    );
  }

  // Hastalarım görünümüne geçiş için kullanılır
  void togglePatientView() {
    if (managementType == MedicineManagementType.allPatients) {
      managementType = MedicineManagementType.myPatients;
    } else {
      managementType = MedicineManagementType.allPatients;
    }
    notifyListeners();

    if (managementType == MedicineManagementType.myPatients) {
      getMyPatients();
    } else {
      getHospitalizations();
    }
  }

  void getMyPatients() async {
    await execute(
      fetchMyPatientsOp,
      operation: () => _getMyPatientsUseCase.call(),
      onData: (data) {
        _myPatients = data.map((d) => d.hospitalization ?? Hospitalization()).toList();
        allItems = _myPatients;
      },
    );
  }

  void createUrgentPatient({
    Function()? onLoading,
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    onLoading?.call();
    final serviceId = _selectedService?.id ?? 0;
    await execute(
      urgentOp,
      operation: () => _createUrgentPatientUseCase.call(serviceId),
      onData: (hospitalization) {
        _urgentPatient = hospitalization;
        onSuccess?.call('Acil hasta oluşturma işlemi başarılı. Alım işlemine yönlendiriliyorsunuz..');
        getHospitalizations();
        notifyListeners();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  void changeFilter(PatientFilterType filter) {
    _filterType = filter;
    notifyListeners();
    _fetchFilteredHospitalizations();
  }

  void toggleOrderlessStatus() {
    _viewOrderStatus = _viewOrderStatus.isOrderless ? OrderStatus.ordered : OrderStatus.orderless;

    // Ordersıza geçince ilk servisi seç, orderlıya geçince sıfırla
    _selectedService = _viewOrderStatus.isOrderless && availableServices.isNotEmpty ? availableServices.first : null;

    getHospitalizations();
    notifyListeners();
  }

  void toggleService(HospitalService? service) {
    _selectedService = (_selectedService?.id == service?.id) ? null : service;
    _fetchHospitalizations();
    notifyListeners();
  }
}
