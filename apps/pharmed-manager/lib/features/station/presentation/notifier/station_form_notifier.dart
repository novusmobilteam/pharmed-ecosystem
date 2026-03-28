import 'package:flutter/material.dart';

import '../../../../core/core.dart';

import '../../../service/domain/entity/service.dart';
import '../../../warehouse/domain/entity/warehouse.dart';
import '../../domain/entity/station.dart';
import '../../domain/usecase/create_station_usecase.dart';
import '../../domain/usecase/get_station_usecase.dart';
import '../../domain/usecase/update_station_usecase.dart';

class StationFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetStationUseCase _getStationUseCase;
  final CreateStationUseCase _createStationUseCase;
  final UpdateStationUseCase _updateStationUseCase;

  StationFormNotifier({
    required GetStationUseCase getStationUseCase,
    required CreateStationUseCase createStationUseCase,
    required UpdateStationUseCase updateStationUseCase,
    Station? station,
  }) : _getStationUseCase = getStationUseCase,
       _createStationUseCase = createStationUseCase,
       _updateStationUseCase = updateStationUseCase;

  Station? _station;
  Station? get station => _station;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.submit();

  bool get isFetching => isLoading(fetchOp);
  bool get isSubmitting => isLoading(submitOp);

  bool get isCreate => _station?.id == null;

  String? get statusMessage => message(submitOp);

  Future<void> initialize({Station? station}) async {
    debugPrint('Station: ${station?.name} - ${station?.id} ');
    final stationId = station?.id;
    if (stationId == null) {
      _station = Station(drugStatus: OrderStatus.ordered, medicalConsumableStatus: OrderStatus.ordered);
      return;
    }
    await execute(
      fetchOp,
      operation: () => _getStationUseCase.call(stationId),
      onData: (data) {
        debugPrint('Data: ${data?.name}');
        if (data != null) _station = data;
      },
    );

    notifyListeners();
  }

  void updateName(String? value) {
    _station = _station?.copyWith(name: value);
    notifyListeners();
  }

  void updateMaterialWarehouse(Warehouse? value) {
    _station = _station?.copyWith(materialWarehouse: value);
    notifyListeners();
  }

  void updateDrugStatus(OrderStatus? status) {
    _station = _station?.copyWith(drugStatus: status);
    notifyListeners();
  }

  void updateConsumableWarehouse(Warehouse? value) {
    _station = _station?.copyWith(medicalConsumableWarehouse: value);
    notifyListeners();
  }

  void updateConsumablesStatus(OrderStatus? status) {
    _station = _station?.copyWith(medicalConsumableStatus: status);
    notifyListeners();
  }

  void updateService(HospitalService? value) {
    _station = _station?.copyWith(service: value);
    notifyListeners();
  }

  void updateProvidedServices(List<HospitalService>? value) {
    _station = _station?.copyWith(services: value);
    notifyListeners();
  }

  Future<void> submit() async {
    if (_station == null) return;
    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createStationUseCase.call(_station!) : _updateStationUseCase.call(_station!),
      onSuccess: () {
        if (isCreate) resetForm();
      },
      successMessage: 'İstasyon başarıyla ${isCreate ? 'oluşturuldu' : 'güncellendi'}',
    );
  }

  void resetForm() {
    _station = Station();
    notifyListeners();
  }
}
