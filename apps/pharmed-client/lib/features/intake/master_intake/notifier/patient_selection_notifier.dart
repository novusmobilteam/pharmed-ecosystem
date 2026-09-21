import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_client/core/providers/providers.dart';
import 'package:pharmed_client/features/auth/auth.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../service_selection/service_selection.dart';

final patientSelection2NotifierProvider = ChangeNotifierProvider.autoDispose<PatientSelectionNotifier2>((ref) {
  return PatientSelectionNotifier2(
    authNotifier: ref.read(authNotifierProvider.notifier),
    getHospitalizationsByServiceUseCase: ref.read(getHospitalizationsByServiceUseCaseProvider),
    activeServiceNotifier: ref.read(activeServiceNotifierProvider),
    createUrgentPatientUseCase: ref.read(createUrgentPatientUseCaseProvider),
    deleteUrgentPatientUseCase: ref.read(deleteUrgentPatientUseCaseProvider),
  );
});

enum HospitalizationType { all, myPatients }

class PatientSelectionNotifier2 extends ChangeNotifier with ApiRequestMixin {
  final AuthNotifier _authNotifier;
  final ActiveServiceNotifier _activeServiceNotifier;
  final GetHospitalizationsByServiceUseCase _getHospitalizationsByServiceUseCase;
  final CreateUrgentPatientUseCase _createUrgentPatientUseCase;
  final DeleteUrgentPatientUseCase _deleteUrgentPatientUseCase;

  PatientSelectionNotifier2({
    required AuthNotifier authNotifier,
    required GetHospitalizationsByServiceUseCase getHospitalizationsByServiceUseCase,
    required ActiveServiceNotifier activeServiceNotifier,
    required CreateUrgentPatientUseCase createUrgentPatientUseCase,
    required DeleteUrgentPatientUseCase deleteUrgentPatientUseCase,
  }) : _authNotifier = authNotifier,
       _activeServiceNotifier = activeServiceNotifier,
       _getHospitalizationsByServiceUseCase = getHospitalizationsByServiceUseCase,
       _createUrgentPatientUseCase = createUrgentPatientUseCase,
       _deleteUrgentPatientUseCase = deleteUrgentPatientUseCase {
    _getHospitalizations();
  }

  int get _activeServiceId => _activeServiceNotifier.activeService?.id ?? 0;
  Station? get _currentStation => _activeServiceNotifier.station;
  AppUser? get _currentUser => _authNotifier.currentUser;

  List<HospitalService> get availableServices => _currentStation?.services ?? [];

  final OperationKey fetchHospitalizationsOp = OperationKey.custom('fetch-hospitalizations');
  final OperationKey createUrgentPatientOp = OperationKey.custom('create-urgent-patient');
  final OperationKey deleteUrgentPatientOp = OperationKey.custom('delete-urgent-patient');

  List<Hospitalization> _hospitalizations = [];
  List<Hospitalization> get hospitalizations => _hospitalizations;

  Hospitalization? _selectedHospitalization;
  Hospitalization? get selectedHospitalization => _selectedHospitalization;

  Hospitalization? _urgentPatient;
  Hospitalization? get urgentPatient => _urgentPatient;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  HospitalizationType _type = HospitalizationType.all;
  HospitalizationType get type => _type;

  /// Acil hasta oluşturulduğunda set edilecek değer.
  /// Sadece serbest ve acil olabilir. Bu değere göre alım yapılacak ilaçların çekildiği servis değişiyor.
  IntakeType _intakeType = IntakeType.free;
  IntakeType get intakeType => _intakeType;

  PatientFilterType _patientFilterType = PatientFilterType.all;
  PatientFilterType get patientFilterType => _patientFilterType;

  int get selectedIndex => HospitalizationType.values.indexOf(_type);

  bool get canCreateUrgentPatient {
    return (_currentStation?.canCreateEmergencyPatient ?? false) && (_currentUser?.canCreateEmergencyPatient ?? false);
  }

  List<Hospitalization> get filteredHospitalizations {
    final q = _searchQuery.toLowerCase();
    if (q.isEmpty) return _hospitalizations;
    return _hospitalizations.where((h) {
      final name = h.patient?.fullName.toLowerCase() ?? '';
      final room = h.bed?.room?.name?.toLowerCase() ?? h.room?.name?.toLowerCase() ?? '';
      return name.contains(q) || room.contains(q);
    }).toList();
  }

  void selectType(HospitalizationType type) {
    _type = type;
    notifyListeners();
    _getHospitalizations();
  }

  void selectFilterType(PatientFilterType? type) {
    _patientFilterType = type ?? PatientFilterType.all;
    notifyListeners();
    _getHospitalizations();
  }

  Future<void> _getHospitalizations() async {
    await execute(
      fetchHospitalizationsOp,
      operation: () => _getHospitalizationsByServiceUseCase.call(
        serviceId: _activeServiceId,
        filter: _patientFilterType,
        myPatients: _type == HospitalizationType.myPatients,
      ),
      onData: (hospitalizations) {
        _hospitalizations = hospitalizations;
        notifyListeners();
      },
    );
  }

  void selectHospitalization(Hospitalization hosp) {
    if (_selectedHospitalization?.id == hosp.id) {
      _selectedHospitalization = null;
      notifyListeners();
      return;
    }
    _selectedHospitalization = hosp;
    notifyListeners();
  }

  void onSearchChanged(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> createUrgentPatient(IntakeType type) async {
    _intakeType = type;
    notifyListeners();
    await execute(
      createUrgentPatientOp,
      operation: () => _createUrgentPatientUseCase.call(_activeServiceId),
      onData: (hosp) {
        _selectedHospitalization = null;
        _urgentPatient = hosp;
        notifyListeners();
      },
    );
  }

  Future<void> deleteUrgentPatient() async {
    final id = _urgentPatient?.patient?.id;
    if (id == null) return;
    await executeVoid(
      deleteUrgentPatientOp,
      operation: () => _deleteUrgentPatientUseCase.call(id),
      onSuccess: () {
        _urgentPatient = null;
        notifyListeners();
      },
    );
  }

  void clearSelections() {
    _selectedHospitalization = null;
  }
}
