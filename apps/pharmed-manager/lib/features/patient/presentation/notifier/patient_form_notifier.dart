import 'package:flutter/material.dart';

import '../../../../core/core.dart';

import '../../domain/entity/patient.dart';
import '../../domain/usecase/create_patient_usecase.dart';
import '../../domain/usecase/update_patient_usecase.dart';

class PatientFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreatePatientUseCase _createPatientUseCase;
  final UpdatePatientUseCase _updatePatientUseCase;

  PatientFormNotifier({
    required CreatePatientUseCase createPatientUseCase,
    required UpdatePatientUseCase updatePatientUseCase,
    Patient? initial,
  }) : _createPatientUseCase = createPatientUseCase,
       _updatePatientUseCase = updatePatientUseCase {
    if (initial != null) {
      _patient = initial;
    } else {
      _patient = Patient(gender: Gender.unknown);
    }
  }

  Patient? _patient;
  Patient? get patient => _patient;

  bool get isCreate => _patient?.id == null ? true : false;

  OperationKey submitOp = OperationKey.submit();

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createPatientUseCase.call(_patient!) : _updatePatientUseCase.call(_patient!),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı.'),
    );
  }

  void updateIdentity(String? value) {
    _patient = _patient?.copyWith(tcNo: value);
    notifyListeners();
  }

  void updateName(String? value) {
    _patient = _patient?.copyWith(name: value);
    notifyListeners();
  }

  void updateSurname(String? value) {
    _patient = _patient?.copyWith(surname: value);
    notifyListeners();
  }

  void updateBirthdate(DateTime? value) {
    _patient = _patient?.copyWith(birthDate: value);
    notifyListeners();
  }

  void updateGender(Gender? value) {
    _patient = _patient?.copyWith(gender: value);
    notifyListeners();
  }

  void updateWeight(String? value) {
    _patient = _patient?.copyWith(weight: int.tryParse(value ?? ''));
    notifyListeners();
  }

  void updateFather(String? value) {
    _patient = _patient?.copyWith(fatherName: value);
    notifyListeners();
  }

  void updateMother(String? value) {
    _patient = _patient?.copyWith(motherName: value);
    notifyListeners();
  }

  void updatePhone(String? value) {
    _patient = _patient?.copyWith(phone: value);
    notifyListeners();
  }

  void updateDescription(String? value) {
    _patient = _patient?.copyWith(description: value);
    notifyListeners();
  }

  void updateAddress(String? value) {
    _patient = _patient?.copyWith(address: value);
    notifyListeners();
  }

  void updateProtocolNo(String? value) {
    _patient = _patient?.copyWith(protocolNo: value);
    notifyListeners();
  }
}
