import 'package:flutter/material.dart';

import '../../../../core/core.dart';

import '../../../branch/domain/entity/branch.dart';
import '../../domain/entity/service.dart';
import '../../domain/usecase/create_service_usecase.dart';
import '../../domain/usecase/update_service_usecase.dart';

class ServiceFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateServiceUseCase _createServiceUseCase;
  final UpdateServiceUseCase _updateServiceUseCase;
  HospitalService _service;

  ServiceFormNotifier({
    required CreateServiceUseCase createServiceUseCase,
    required UpdateServiceUseCase updateServiceUseCase,
    HospitalService? service,
  }) : _createServiceUseCase = createServiceUseCase,
       _updateServiceUseCase = updateServiceUseCase,
       _service = service ?? HospitalService(isActive: true);

  OperationKey submitOp = OperationKey.submit();

  HospitalService get service => _service;
  bool get isCreate => _service.id == null;

  bool get isSubmitting => isLoading(submitOp);
  String? get statusMessage => message(submitOp);

  void updateName(String? value) {
    _service = _service.copyWith(name: value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _service = _service.copyWith(isActive: value?.isActive);
    notifyListeners();
  }

  void updateBranch(Branch? value) {
    _service = _service.copyWith(branch: value);
    notifyListeners();
  }

  void updateUser(User? value) {
    _service = _service.copyWith(user: value);
    notifyListeners();
  }

  Future<void> submit() async {
    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createServiceUseCase.call(_service) : _updateServiceUseCase.call(_service),
      onSuccess: () {
        if (isCreate) resetForm();
      },
      successMessage: 'Firma başarıyla ${isCreate ? 'oluşturuldu' : 'güncellendi'}',
    );
  }

  void resetForm() {
    _service = HospitalService(isActive: true);
    notifyListeners();
  }
}
