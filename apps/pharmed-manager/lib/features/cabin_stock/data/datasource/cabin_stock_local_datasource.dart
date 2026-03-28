import '../model/station_stock_dto.dart';

import '../../../../core/core.dart';
import '../model/cabin_stock_dto.dart';
import 'cabin_stock_datasource.dart';

class _CabinDrawerStockStore extends BaseLocalDataSource<CabinStockDTO, int> {
  _CabinDrawerStockStore({required super.filePath})
      : super(
          fromJson: (m) => CabinStockDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => d.copyWith(id: id),
        );
}

class CabinStockLocalDataSource implements CabinStockDataSource {
  final _CabinDrawerStockStore _store;

  CabinStockLocalDataSource({required String assetPath}) : _store = _CabinDrawerStockStore(filePath: assetPath);

  @override
  Future<Result<List<CabinStockDTO>>> getStocks(int cabinId) async {
    final res = await _store.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<CabinStockDTO>>> getExpiringStocks() async {
    return _store.fetchAll();
  }

  @override
  Future<Result<CabinStockDTO?>> getMedicineInfo(int medicineId) async {
    return Result.ok(CabinStockDTO());
  }

  @override
  Future<Result<void>> fill(List<dynamic> data) async {
    return Result.ok(null);
  }

  @override
  Future<Result<void>> count(List<dynamic> data) async {
    return Result.ok(null);
  }

  @override
  Future<Result<List<CabinStockDTO>>> getCurrentCabinStock() async {
    return Result.ok([]);
  }

  @override
  Future<Result<List<CabinStockDTO>>> getExpiredStocks() async {
    return _store.fetchAll();
  }

  @override
  Future<Result<List<StationStockDTO>>> getStationStocks(int stationId) async {
    return Result.ok([]);
  }

  @override
  Future<Result<void>> unload(List<Map<String, dynamic>> data) async {
    return Result.ok(null);
  }
}
