import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class ServiceNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<HospitalService> {
  final GetServicesUseCase _getServicesUseCase;
  final DeleteServiceUseCase _deleteServiceUseCase;

  ServiceNotifier({required GetServicesUseCase getServicesUseCase, required DeleteServiceUseCase deleteServiceUseCase})
    : _getServicesUseCase = getServicesUseCase,
      _deleteServiceUseCase = deleteServiceUseCase;

  OperationKey deleteOp = OperationKey.delete();
  OperationKey fetchOp = OperationKey.fetch();

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      fetchMethod: (skip, take) => _getServicesUseCase.call(
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
      ),
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
        onSuccess?.call(null);
        fetch();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
