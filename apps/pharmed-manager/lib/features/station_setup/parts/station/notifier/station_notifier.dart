import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class StationNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Station> {
  final GetStationsUseCase _getStationsUseCase;
  final DeleteStationUseCase _deleteStationUseCase;

  StationNotifier({required GetStationsUseCase getStationsUseCase, required DeleteStationUseCase deleteStationUseCase})
    : _getStationsUseCase = getStationsUseCase,
      _deleteStationUseCase = deleteStationUseCase;

  OperationKey deleteOp = OperationKey.delete();
  OperationKey fetchOp = OperationKey.fetch();

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      fetchMethod: (skip, take) => _getStationsUseCase.call(
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
      ),
    );
  }

  Future<void> deleteStation(
    Station station, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteStationUseCase.call(station),
      onSuccess: () {
        onSuccess?.call(null);
        fetch();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
