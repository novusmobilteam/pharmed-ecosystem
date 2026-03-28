import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../patient/domain/entity/patient.dart';
import '../../../patient/domain/entity/urgent_patient.dart';
import '../../../patient/domain/usecase/end_emergency_patient_usecase.dart';
import '../../../patient/domain/usecase/get_patients_usecase.dart';
import '../../../prescription/domain/entity/prescription_item.dart';
import '../../domain/usecase/get_urgent_patients_usecase.dart';

class UrgentPatientNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<UrgentPatient> {
  final GetUrgentPatientsUseCase _getUrgentPatientsUseCase;
  final GetPatientsUseCase _getPatientsUseCase;
  final EndEmergencyPatientUseCase _emergencyPatientUseCase;

  UrgentPatientNotifier({
    required GetUrgentPatientsUseCase getUrgentPatientsUseCase,
    required GetPatientsUseCase getPatientsUseCase,
    required EndEmergencyPatientUseCase emergencyPatientUseCase,
  }) : _getUrgentPatientsUseCase = getUrgentPatientsUseCase,
       _getPatientsUseCase = getPatientsUseCase,
       _emergencyPatientUseCase = emergencyPatientUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey fetchHospOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.submit();

  List<Patient> _patients = [];
  List<Patient> get patients => _patients;

  UrgentPatient? _selectedUrgentPatient;
  UrgentPatient? get selectedUrgentPatient => _selectedUrgentPatient;

  Patient? _selectedPatient;
  Patient? get selectedPatient => _selectedPatient;

  bool get isFetching => isLoading(fetchOp);

  Set<int> _selectedItemIds = {};
  Set<int> get selectedItemIds => _selectedItemIds;

  Future<void> getUrgentPatients() async {
    await execute(fetchOp, operation: () => _getUrgentPatientsUseCase.call(), onData: (data) => allItems = data);
  }

  Future<void> getHospitalizations() async {
    await execute(
      fetchHospOp,
      operation: () => _getPatientsUseCase.call(GetPatientsParams()),
      onData: (response) {
        _patients = response.data ?? [];
        notifyListeners();
      },
    );
  }

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    final params = EndEmergencyPatientParams(
      hospitalizationId: _selectedUrgentPatient?.id ?? 0,
      patientId: _selectedPatient?.id ?? 0,
      prescriptionItemIds: _selectedItemIds.toList(),
    );

    await executeVoid(
      submitOp,
      operation: () => _emergencyPatientUseCase.call(params),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı.');
        _selectedPatient = null;
        getUrgentPatients();
      },
    );
  }

  void selectPatient(Patient patient) {
    _selectedPatient = patient;
    notifyListeners();
  }

  void selectUrgentPatient(UrgentPatient patient) {
    if (_selectedUrgentPatient?.id == patient.id) {
      // Aynı hastaya tekrar basıldıysa seçimi kaldır
      _selectedUrgentPatient = null;
      _selectedItemIds.clear();
    } else {
      // Yeni hasta seçildi → tüm ilaçları otomatik seç
      _selectedUrgentPatient = patient;
      _selectedItemIds.clear();
      patient.prescriptionItems?.forEach((p) {
        _selectedItemIds.add(p.id ?? 0);
      });
    }

    notifyListeners();
  }

  void selectItem(PrescriptionItem item, UrgentPatient patientData) {
    // Seçili hasta yoksa veya farklı hastaya aitse önce hastayı seç
    if (_selectedUrgentPatient?.id != patientData.id) {
      _selectedUrgentPatient = patientData;
      _selectedItemIds.clear();
    }

    if (_selectedItemIds.contains(item.id)) {
      _selectedItemIds.remove(item.id);

      // Tüm ilaçlar kaldırılırsa hastayı da kaldır
      if (_selectedItemIds.isEmpty) {
        _selectedUrgentPatient = null;
      }
    } else {
      _selectedItemIds.add(item.id ?? 0);
    }

    notifyListeners();
  }
}
