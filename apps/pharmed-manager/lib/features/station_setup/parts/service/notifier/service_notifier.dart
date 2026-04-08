import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class ServiceNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<HospitalService> {
  final GetServicesUseCase _getServicesUseCase;
  final DeleteServiceUseCase _deleteServiceUseCase;

  ServiceNotifier({required GetServicesUseCase getServicesUseCase, required DeleteServiceUseCase deleteServiceUseCase})
    : _getServicesUseCase = getServicesUseCase,
      _deleteServiceUseCase = deleteServiceUseCase;

  OperationKey deleteOp = OperationKey.delete();
  OperationKey fetchOp = OperationKey.fetch();

  Future<void> getServices() async {
    await execute(
      fetchOp,
      operation: () => _getServicesUseCase.call(GetServicesParams()),
      onData: (response) {
        if (response.data != null) {
          allItems = response.data!;
        }
      },
    );
  }

  Future<void> deleteService(
    HospitalService service, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteServiceUseCase.call(service),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı.');
        getServices();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
