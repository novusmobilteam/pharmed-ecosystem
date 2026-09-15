import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_client/features/auth/auth.dart';
import 'package:pharmed_client/features/dashboard/dashboard.dart';
import 'package:pharmed_client/features/service_selection/notifier/active_service_notifier.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/providers/providers.dart';

final myPatientsNotifierProvider = ChangeNotifierProvider<MyPatientsNotifier>((ref) {
  return MyPatientsNotifier(
    authNotifier: ref.read(authNotifierProvider.notifier),
    getBedAssignmentsUseCase: ref.read(getBedAssignmentsUseCaseProvider),
    getActiveHospitalizationsUseCase: ref.read(getHospitalizationsByServiceUseCaseProvider),
    getMyPatientsUseCase: ref.read(getMyPatientsUseCaseProvider),
    addPatientUseCase: ref.read(addPatientUseCaseProvider),
    removePatientsUseCase: ref.read(removePatientsUseCaseProvider),
    activeServiceNotifier: ref.read(activeServiceNotifierProvider),
  );
});

class MyPatientsNotifier extends ChangeNotifier with ApiRequestMixin {
  final AuthNotifier _authNotifier;
  final GetBedAssignmentsUseCase _getBedAssignmentsUseCase;
  final GetHospitalizationsByServiceUseCase _getActiveHospitalizationsUseCase;
  final GetMyPatientsUseCase _getMyPatientsUseCase;
  final AddPatientUseCase _addPatientUseCase;
  final RemovePatientsUseCase _removePatientsUseCase;
  final ActiveServiceNotifier _activeServiceNotifier;

  MyPatientsNotifier({
    required AuthNotifier authNotifier,
    required GetBedAssignmentsUseCase getBedAssignmentsUseCase,
    required GetHospitalizationsByServiceUseCase getActiveHospitalizationsUseCase,
    required GetMyPatientsUseCase getMyPatientsUseCase,
    required AddPatientUseCase addPatientUseCase,
    required RemovePatientsUseCase removePatientsUseCase,
    required ActiveServiceNotifier activeServiceNotifier,
  }) : _authNotifier = authNotifier,
       _getBedAssignmentsUseCase = getBedAssignmentsUseCase,
       _getActiveHospitalizationsUseCase = getActiveHospitalizationsUseCase,
       _getMyPatientsUseCase = getMyPatientsUseCase,
       _addPatientUseCase = addPatientUseCase,
       _removePatientsUseCase = removePatientsUseCase,
       _activeServiceNotifier = activeServiceNotifier;

  final OperationKey fetchHospitalizationsOp = OperationKey.custom('fetch-hospitalizations');
  final OperationKey fetchMyPatientsOp = OperationKey.custom('fetch-my-patients');
  final OperationKey addPatientOp = OperationKey.custom('add-patient');
  final OperationKey removePatientOp = OperationKey.custom('remove-patient');

  int get _currentUserId => _authNotifier.currentUser?.id ?? 0;
  int get _activeServiceId => _activeServiceNotifier.activeService?.id ?? 0;

  List<Hospitalization> _hospitalizations = [];
  List<Hospitalization> get hospitalizations => _hospitalizations;

  List<MyPatient> _myPatients = [];
  List<MyPatient> get myPatients => _myPatients;

  String _search = '';
  String get search => _search;

  Set<int> get myPatientHospitalizationIds => myPatients.map((p) => p.hospitalization?.id).whereType<int>().toSet();

  bool get isInitiallyLoading =>
      (isLoading(fetchHospitalizationsOp) && _hospitalizations.isEmpty) ||
      (isLoading(fetchMyPatientsOp) && _myPatients.isEmpty);

  bool get isError => isFailed(fetchHospitalizationsOp) || isFailed(fetchMyPatientsOp);

  Set<int> _pendingIds = {};
  bool isPending(int hospitalizationId) => _pendingIds.contains(hospitalizationId);

  List<Hospitalization> get filteredHospitalizations {
    final q = _search.toLowerCase();
    if (q.isEmpty) return _hospitalizations;
    return _hospitalizations.where((h) {
      final name = h.patient?.fullName.toLowerCase() ?? '';
      final room = h.bed?.room?.name?.toLowerCase() ?? h.room?.name?.toLowerCase() ?? '';
      return name.contains(q) || room.contains(q);
    }).toList();
  }

  Future<void> init(CabinRouteContext? ctx) async {
    final cabinType = ctx?.deviceMode;
    final isMobile = cabinType == CabinType.mobile;

    await Future.wait([isMobile ? _getBedAssignments() : _getActiveHospitalizations(), _getMyPatients()]);
  }

  Future<void> _getBedAssignments() async {
    await execute(
      fetchHospitalizationsOp,
      operation: () => _getBedAssignmentsUseCase.call(),
      onData: (assignments) {
        _hospitalizations = _toHospitalizations(assignments);
        notifyListeners();
      },
    );
  }

  Future<void> _getActiveHospitalizations() async {
    await execute(
      fetchHospitalizationsOp,
      operation: () =>
          _getActiveHospitalizationsUseCase.call(serviceId: _activeServiceId, filter: PatientFilterType.all),
      onData: (hospitalizations) {
        _hospitalizations = hospitalizations;
        notifyListeners();
      },
    );
  }

  Future<void> _getMyPatients() async {
    await execute(
      fetchMyPatientsOp,
      operation: () => _getMyPatientsUseCase.call(),
      onData: (patients) {
        _myPatients = patients;
        notifyListeners();
      },
    );
  }

  Future<void> addPatient(
    Hospitalization hospitalization, {
    Function(String? msg)? onFailed,
    VoidCallback? onSuccess,
  }) async {
    final hospId = hospitalization.id;
    if (hospId == null) return;

    if (myPatientHospitalizationIds.contains(hospId)) return;

    _pendingIds = {..._pendingIds, hospId};
    notifyListeners();

    await executeVoid(
      addPatientOp,
      operation: () => _addPatientUseCase.call(AddPatientParams(userId: _currentUserId, hospitalizationId: hospId)),
      onFailed: (error) {
        _pendingIds = {..._pendingIds}..remove(hospId);
        notifyListeners();
        onFailed?.call(error.message);
      },
      onSuccess: () {
        _pendingIds = {..._pendingIds}..remove(hospId);
        onSuccess?.call();
        _getMyPatients();
      },
    );
  }

  Future<void> removePatient(MyPatient patient, {Function(String? msg)? onFailed, VoidCallback? onSuccess}) async {
    final myPatientId = patient.id;
    final hospId = patient.hospitalization?.id;
    if (myPatientId == null || hospId == null) return;

    _pendingIds = {..._pendingIds, hospId};
    notifyListeners();

    await executeVoid(
      removePatientOp,
      operation: () => _removePatientsUseCase.call([myPatientId]),
      onFailed: (error) {
        _pendingIds = {..._pendingIds}..remove(hospId);
        notifyListeners();
        onFailed?.call(error.message);
      },
      onSuccess: () {
        _pendingIds = {..._pendingIds}..remove(hospId);
        onSuccess?.call();
        _getMyPatients();
      },
    );
  }

  void onSearchChanged(String value) {
    _search = value;
    notifyListeners();
  }

  List<Hospitalization> _toHospitalizations(List<BedAssignment> assignments) {
    return assignments.map((a) => a.hospitalization).whereType<Hospitalization>().toList();
  }
}
