import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class StationNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<Station> {
  final GetStationsUseCase _getStationsUseCase;
  final DeleteStationUseCase _deleteStationUseCase;

  StationNotifier({required GetStationsUseCase getStationsUseCase, required DeleteStationUseCase deleteStationUseCase})
    : _getStationsUseCase = getStationsUseCase,
      _deleteStationUseCase = deleteStationUseCase;

  OperationKey deleteOp = OperationKey.delete();
  OperationKey fetchOp = OperationKey.fetch();

  Future<void> getStations() async {
    await execute(
      fetchOp,
      operation: () => _getStationsUseCase.call(GetStationsParams()),
      onData: (response) {
        if (response.data != null) {
          allItems = response.data!;
        }
      },
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
        onSuccess?.call('İşleminiz başarıyla tamamlandı');
        getStations();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
