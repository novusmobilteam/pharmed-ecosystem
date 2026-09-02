import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/mixins/api_request_mixin.dart';
import '../../../core/providers/providers.dart';

final urgentPatientNotifierProvider = ChangeNotifierProvider.autoDispose<UrgentPatientNotifier>(
  (ref) => UrgentPatientNotifier(
    deleteUrgentPatientUseCase: ref.read(deleteUrgentPatientUseCaseProvider),
    emergencyPatientUseCase: ref.read(endUrgentPatientUseCaseProvider),
    getUrgentPatientsUseCase: ref.read(getUrgentPatientsUseCaseProvider),
  )..getUrgentPatients(),
);

class UrgentPatientNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetUrgentPatientsUseCase _getUrgentPatientsUseCase;
  final EndUrgentPatientUseCase _emergencyPatientUseCase;
  final DeleteUrgentPatientUseCase _deleteUrgentPatientUseCase;

  UrgentPatientNotifier({
    required GetUrgentPatientsUseCase getUrgentPatientsUseCase,
    required DeleteUrgentPatientUseCase deleteUrgentPatientUseCase,
    required EndUrgentPatientUseCase emergencyPatientUseCase,
  }) : _getUrgentPatientsUseCase = getUrgentPatientsUseCase,
       _emergencyPatientUseCase = emergencyPatientUseCase,
       _deleteUrgentPatientUseCase = deleteUrgentPatientUseCase {
    // getUrgentPatients();
  }

  final OperationKey _fetchUrgentOp = OperationKey.custom('fetch-urgent');
  final OperationKey _submitOp = OperationKey.custom('submit-emergency');
  final OperationKey _deleteOp = OperationKey.delete();

  List<Hospitalization> _hospitalization = [];
  List<Hospitalization> get hospitalization => _hospitalization;

  List<UrgentPatient> _urgentPatients = [];
  List<UrgentPatient> get urgentPatients => _urgentPatients;

  Hospitalization? _selectedPatient;
  Hospitalization? get selectedPatient => _selectedPatient;

  UrgentPatient? _selectedUrgentPatient;
  UrgentPatient? get selectedUrgentPatient => _selectedUrgentPatient;

  bool get isFetching => isLoading(_fetchUrgentOp);
  bool get isSubmitting => isLoading(_submitOp);
  bool get isDeleting => isLoading(_deleteOp);

  Future<void> getUrgentPatients() async {
    await execute(
      _fetchUrgentOp,
      operation: () => _getUrgentPatientsUseCase.call(),
      onData: (data) {
        _urgentPatients = data;
        notifyListeners();
      },
    );
  }

  Future<void> submit({Function(String? msg)? onFailed, VoidCallback? onSuccess}) async {
    if (_selectedUrgentPatient?.prescriptionItems == null) return;

    final params = EndUrgentPatientParams(
      hospitalizationId: _selectedUrgentPatient?.id ?? 0,
      patientId: _selectedPatient?.id ?? 0,
      prescriptionItemIds: _selectedUrgentPatient!.prescriptionItems!.map((m) => m.id ?? 0).toList(),
    );

    await executeVoid(
      _submitOp,
      operation: () => _emergencyPatientUseCase.call(params),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call();
        _selectedPatient = null;
        getUrgentPatients();
      },
    );
  }

  Future<void> deleteUrgentPatient({Function(String? msg)? onFailed, VoidCallback? onSuccess}) async {
    final patientId = _selectedUrgentPatient?.id;
    if (patientId == null) return;
    await executeVoid(
      _deleteOp,
      operation: () => _deleteUrgentPatientUseCase.call(patientId),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call();
        _selectedPatient = null;
        getUrgentPatients();
      },
    );
  }

  void selectPatient(Hospitalization patient) {
    _selectedPatient = patient;
    notifyListeners();
  }

  void selectUrgentPatient(UrgentPatient patient) {
    _selectedUrgentPatient = patient;
    notifyListeners();
  }
}
