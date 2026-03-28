import '../../../../core/core.dart';
import '../../domain/entity/cabin_stock.dart';
import '../../domain/entity/station_stock.dart';
import '../../domain/repository/i_cabin_stock_repository.dart';
import '../datasource/cabin_stock_datasource.dart';

class CabinStockRepository implements ICabinStockRepository {
  final CabinStockDataSource _ds;

  CabinStockRepository(this._ds);

  @override
  Future<Result<List<CabinStock>>> getStocks(int cabinId) async {
    final res = await _ds.getStocks(cabinId);

    return res.when(
      ok: (list) {
        final entities = list.map((d) => d.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<List<CabinStock>>> getExpiringStocks() async {
    final res = await _ds.getExpiringStocks();

    return res.when(
      ok: (data) {
        List<CabinStock> entities = [];
        entities = data.map((d) => d.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<CabinStock?>> getMedicineInfo(int medicineId) async {
    final res = await _ds.getMedicineInfo(medicineId);

    return res.when(
      ok: (data) {
        final entity = data?.toEntity();
        return Result.ok(entity);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<void>> fill(List<dynamic> data) async {
    return await _ds.fill(data);
  }

  @override
  Future<Result<void>> count(List<dynamic> data) async {
    return await _ds.count(data);
  }

  @override
  Future<Result<List<CabinStock>>> getCurrentCabinStock() async {
    final res = await _ds.getCurrentCabinStock();

    return res.when(
      ok: (list) {
        final entities = list.map((d) => d.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<List<CabinStock>>> getExpiredStocks() async {
    final res = await _ds.getExpiredStocks();

    return res.when(
      ok: (list) {
        final entities = list.map((d) => d.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<List<StationStock>>> getStationStocks(int stationId) async {
    final r = await _ds.getStationStocks(stationId);
    return r.when(
      ok: (dtos) {
        final entities = (dtos).map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (err) {
        return Result.error(err);
      },
    );
  }

  @override
  Future<Result<void>> unload(List<Map<String, dynamic>> data) async {
    return _ds.unload(data);
  }
}
