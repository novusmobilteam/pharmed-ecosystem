import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmed_manager/core/core.dart';

import '../data/repository/cabin_temperature_repository_impl.dart';
import '../domain/entity/cabin_temperature.dart';
import '../domain/entity/cabin_temperature_detail.dart';

class CabinTemperatureViewModel extends ChangeNotifier with ApiRequestMixin, SearchMixin<CabinTemperatureDetail> {
  final CabinTemperatureRepository _cabinTemperatureRepository;
  // BuildContext'e erişimi olmayan bu ViewModel yerine, oluşturulduğu view
  // katmanından (l10n ile) çözülen mesajlar için enjekte edilir.
  final AppLocalizations _l10n;

  CabinTemperatureViewModel({required CabinTemperatureRepository cabinTemperatureRepository, required AppLocalizations l10n})
    : _cabinTemperatureRepository = cabinTemperatureRepository,
      _l10n = l10n;

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
      .map(
        (s) => TableSideCategory(
          id: s.id!.toString(),
          label: s.name ?? _l10n.cabinTemperatureUnnamedStationFallback,
          count: 0,
        ),
      )
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
      loadingMessage: _l10n.cabinTemperatureStationsLoadingMessage,
    );
  }

  Future<void> getDetail() async {
    final station = _selectedStation;
    if (station?.id == null) return;

    await execute(
      getDetailOperation,
      operation: () => _cabinTemperatureRepository.getCabinTemperatureDetails(station!.id!),
      onData: (data) => _temperatureDetails = data,
      loadingMessage: _l10n.cabinTemperatureDetailsLoadingMessage,
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
        // Not: `cabinTemperatureDeleteSuccess` diye özel bir ARB anahtarı
        // oluşturulmamış; bu genel işlem başarı mesajı ile aynı metin
        // (bkz. common_operationSuccessMessage) reuse edilir.
        onSuccess?.call(_l10n.common_operationSuccessMessage);
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
