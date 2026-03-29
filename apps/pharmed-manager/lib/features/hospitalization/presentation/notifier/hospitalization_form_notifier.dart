import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/hospitalization.dart';
import '../../../patient/domain/entity/patient.dart';
import '../../../service/domain/entity/service.dart';
import '../../domain/usecase/create_hospitalization_usecase.dart';
import '../../domain/usecase/update_hospitalization_usecase.dart';

class HospitalizationFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateHospitalizationUseCase _createHospitalizationUseCase;
  final UpdateHospitalizationUseCase _updateHospitalizationUseCase;

  HospitalizationFormNotifier({
    Patient? patient,
    Hospitalization? hospitalization,
    required CreateHospitalizationUseCase createHospitalizationUseCase,
    required UpdateHospitalizationUseCase updateHospitalizationUseCase,
  }) : _createHospitalizationUseCase = createHospitalizationUseCase,
       _updateHospitalizationUseCase = updateHospitalizationUseCase {
    _patient = patient;
    if (hospitalization == null) {
      _hospitalization = Hospitalization(patient: _patient, code: createRandomText(9), admissionDate: DateTime.now());
    } else {
      _hospitalization = hospitalization;
    }
  }

  OperationKey submitOp = OperationKey.submit();

  Hospitalization? _hospitalization;
  Hospitalization? get hospitalization => _hospitalization;

  Patient? _patient;
  Patient? get patient => _patient;

  User? get doctor => _hospitalization?.doctor;

  bool get hasPatient => _patient != null;
  bool get isCreate => _hospitalization?.id == null;

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      submitOp,
      operation: () async => isCreate
          ? await _createHospitalizationUseCase.call(_hospitalization!)
          : await _updateHospitalizationUseCase.call(_hospitalization!),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı'),
    );
  }

  void selectDoctor(User? user) {
    _hospitalization = _hospitalization?.copyWith(doctor: user);
    notifyListeners();
  }

  void selectPhysicalService(HospitalService? service) {
    _hospitalization = _hospitalization?.copyWith(physicalService: service);
    notifyListeners();
  }

  void selectInpatientService(HospitalService? service) {
    _hospitalization = _hospitalization?.copyWith(inpatientService: service);
    notifyListeners();
  }

  void updateRoom(String? value) {
    _hospitalization = _hospitalization?.copyWith(roomNo: value);
    notifyListeners();
  }

  void updateBed(String? value) {
    _hospitalization = _hospitalization?.copyWith(bedNo: value);
    notifyListeners();
  }

  void updateAdmissionDate(DateTime? value) {
    _hospitalization = _hospitalization?.copyWith(admissionDate: value);
    notifyListeners();
  }

  void updateExitDate(DateTime? value) {
    _hospitalization = _hospitalization?.copyWith(exitDate: value);
    notifyListeners();
  }

  void updateDescription(String? value) {
    _hospitalization = _hospitalization?.copyWith(description: value);
    notifyListeners();
  }

  void toggleIsBaby() {
    _hospitalization = _hospitalization?.copyWith(isBaby: !(_hospitalization?.isBaby ?? false));
    notifyListeners();
  }
}
