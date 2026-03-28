import '../../../../core/core.dart';
import '../model/cabin_temperature_dto.dart';
import '../model/cabin_temperature_detail_dto.dart';
import 'cabin_temperature_datasource.dart';

class _CabinTemperatureStore extends BaseLocalDataSource<CabinTemperatureDTO, int> {
  _CabinTemperatureStore({required super.filePath})
      : super(
          fromJson: (m) => CabinTemperatureDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => CabinTemperatureDTO.fromJson({...d.toJson(), 'id': id}),
        );
}

class _CabinTemperatureDetailStore extends BaseLocalDataSource<CabinTemperatureDetailDTO, int> {
  _CabinTemperatureDetailStore({required super.filePath})
      : super(
          fromJson: (m) => CabinTemperatureDetailDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => CabinTemperatureDetailDTO.fromJson({...d.toJson(), 'id': id}),
        );
}

/// Kabin sıcaklık kontrol işlemleri için yerel (Mock) veri kaynağı.
class CabinTemperatureLocalDataSource implements CabinTemperatureDataSource {
  final _CabinTemperatureStore _cabinTemperatureStore;
  final _CabinTemperatureDetailStore _cabinTemperatureDetailStore;

  CabinTemperatureLocalDataSource({
    required String cabinTemperaturePath,
    required String cabinTemperatureDetailPath,
  })  : _cabinTemperatureStore = _CabinTemperatureStore(filePath: cabinTemperaturePath),
        _cabinTemperatureDetailStore = _CabinTemperatureDetailStore(
          filePath: cabinTemperatureDetailPath,
        );

  @override
  Future<Result<CabinTemperatureDTO?>> createCabinTemperature(CabinTemperatureDTO dto) =>
      _cabinTemperatureStore.createRequest(dto);

  @override
  Future<Result<void>> deleteCabinTemperatureDetail(int id) => _cabinTemperatureStore.deleteRequest(id);

  @override
  Future<Result<ApiResponse<List<CabinTemperatureDTO>>>> getCabinTemperatures({
    int? skip,
    int? take,
    String? search,
  }) {
    return _cabinTemperatureStore.fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
    );
  }

  @override
  Future<Result<List<CabinTemperatureDetailDTO>>> getCabinTemperatureDetails(int id) async {
    final res = await _cabinTemperatureDetailStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<CabinTemperatureDetailDTO?>> createCabinTemperatureDetail(CabinTemperatureDetailDTO dto) =>
      _cabinTemperatureDetailStore.createRequest(dto);

  @override
  Future<Result<CabinTemperatureDetailDTO?>> updateCabinTemperatureDetail(CabinTemperatureDetailDTO dto) =>
      _cabinTemperatureDetailStore.updateRequest(dto);
}
