import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../core/widgets/unified_table/unified_table_models.dart';
import '../data/repository/cabin_temperature_repository_impl.dart';
import '../domain/entity/cabin_temperature.dart';
import '../domain/entity/cabin_temperature_detail.dart';
import '../../station/domain/entity/station.dart';

class CabinTemperatureViewModel extends ChangeNotifier with ApiRequestMixin, SearchMixin<CabinTemperatureDetail> {
  final CabinTemperatureRepository _cabinTemperatureRepository;

  CabinTemperatureViewModel({required CabinTemperatureRepository cabinTemperatureRepository})
    : _cabinTemperatureRepository = cabinTemperatureRepository;

  static const getStationsOperation = OperationKey.custom('get_stations');
  static const getDetailOperation = OperationKey.custom('get_detail');
  static const deleteOperation = OperationKey.delete();

  List<CabinTemperature> _temperatures = [];
  List<CabinTemperatureDetail> _temperatureDetails = [];

  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  void selectCategory(String id) {
    if (_selectedCategoryId == id) return;
    _selectedCategoryId = id;
    notifyListeners();
    getDetail();
  }

  List<Station> get _stations => _filterStations(_temperatures);

  List<TableSideCategory> get tableCategories => _stations
      .map((s) => TableSideCategory(id: s.id!.toString(), label: s.name ?? 'İsimsiz İstasyon', count: 0))
      .toList();

  Station? get _selectedStation => _stations.firstWhereOrNull((s) => s.id?.toString() == _selectedCategoryId);

  List<CabinTemperatureDetail> get temperatureDetails => _temperatureDetails;

  bool get isFetchingStations => isLoading(getStationsOperation);
  bool get isFetchingDetail => isLoading(getDetailOperation);
  bool get isDeleting => isLoading(deleteOperation);
  bool get hasStations => _temperatures.isNotEmpty;

  @override
  List<CabinTemperatureDetail> get allItems => _temperatureDetails;

  @override
  set allItems(List<CabinTemperatureDetail> items) => _temperatureDetails = items;

  Future<void> getStations() async {
    await execute(
      getStationsOperation,
      operation: () => _cabinTemperatureRepository.getCabinTemperatures(),
      onData: (data) {
        _temperatures = data;

        final firstId = _stations.firstOrNull?.id?.toString();
        if (firstId != null) {
          _selectedCategoryId = firstId;
          getDetail();
        }
      },
      loadingMessage: 'İstasyonlar yükleniyor...',
    );
  }

  Future<void> getDetail() async {
    final station = _selectedStation;
    if (station?.id == null) return;

    await execute(
      getDetailOperation,
      operation: () => _cabinTemperatureRepository.getCabinTemperatureDetails(station!.id!),
      onData: (data) => _temperatureDetails = data,
      loadingMessage: 'Sıcaklık detayları yükleniyor...',
    );
  }

  Future<void> deleteTemperature(
    CabinTemperatureDetail entity, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    await executeVoid(
      deleteOperation,
      operation: () => _cabinTemperatureRepository.deleteCabinTemperatureDetail(entity),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı');
        getDetail();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  List<Station> _filterStations(List<CabinTemperature> temperatures) {
    final map = <int, Station>{};
    for (final temp in temperatures) {
      if (temp.station?.id != null) map[temp.station!.id!] = temp.station!;
    }
    return map.values.toList();
  }
}
