import '../../../../core/core.dart';
import '../model/cabin_stock_dto.dart';
import '../model/station_stock_dto.dart';
import 'cabin_stock_datasource.dart';

class CabinStockRemoteDataSource extends BaseRemoteDataSource implements CabinStockDataSource {
  CabinStockRemoteDataSource({required super.apiManager});

  final String _basePath = '/CabinDrawrStock';

  /// Belirtilen kabindeki tüm materyal stoklarını çeker.
  @override
  Future<Result<List<CabinStockDTO>>> getStocks(int cabinId) async {
    final res = await fetchRequest<List<CabinStockDTO>>(
      path: '$_basePath/allMaterial/$cabinId',
      parser: listParser(CabinStockDTO.fromJson),
      successLog: 'Cabin Drawer Stocks fetched',
      emptyLog: 'No drawers found',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const <CabinStockDTO>[]),
      error: Result.error,
    );
  }

  /// Son kullanma tarihi yaklaşan (örneğin 14 gün) ürünleri sayfalı olarak getirir.
  @override
  Future<Result<List<CabinStockDTO>>> getExpiringStocks() async {
    final res = await fetchRequest<List<CabinStockDTO>>(
      path: '$_basePath/expirationDate/14',
      parser: listParser(CabinStockDTO.fromJson),
      successLog: 'Expiring materials fetched',
      emptyLog: 'No expiring materials found',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? []),
      error: Result.error,
    );
  }

  /// Tekil bir ilacın dolum/stok bilgisini getirir.
  @override
  Future<Result<CabinStockDTO?>> getMedicineInfo(int medicineId) async {
    final res = await fetchRequest<CabinStockDTO>(
      path: '$_basePath/materialInfo/$medicineId',
      parser: singleParser(CabinStockDTO.fromJson),
      successLog: 'Medicine info fetched',
    );

    return res.when(
      ok: (data) => Result.ok(data),
      error: Result.error,
    );
  }

  /// Dolum isteğini sunucuya iletir.
  @override
  Future<Result<void>> fill(List<dynamic> data) async {
    return await createRequest(
      path: _basePath,
      parser: voidParser(),
      body: data.map((e) => e.toJson()).toList(),
      successLog: 'Filling process completed',
    );
  }

  /// Sayım sonucunu sunucuya iletir (Update/PATCH).
  @override
  Future<Result<void>> count(List<dynamic> data) async {
    return await updateRequest(
      path: '$_basePath/censusQuantity',
      parser: voidParser(),
      body: data.map((e) => e.toJson()).toList(),
      successLog: 'Census quantity updated',
    );
  }

  @override
  Future<Result<List<CabinStockDTO>>> getCurrentCabinStock() async {
    final res = await fetchRequest<List<CabinStockDTO>>(
      path: '$_basePath/currentStationStock',
      parser: listParser(CabinStockDTO.fromJson),
    );

    return res.when(
      ok: (data) => Result.ok(data ?? []),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<CabinStockDTO>>> getExpiredStocks() async {
    final res = await fetchRequest<List<CabinStockDTO>>(
      path: '$_basePath/report/expiredMiadDate',
      parser: listParser(CabinStockDTO.fromJson),
    );

    return res.when(
      ok: (data) => Result.ok(data ?? []),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<StationStockDTO>>> getStationStocks(int stationId) async {
    final res = await fetchRequest<List<StationStockDTO>>(
      path: '$_basePath/stock/$stationId',
      parser: listParser(StationStockDTO.fromJson),
      successLog: 'Station stocks fetched',
      emptyLog: 'No station stocks',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const <StationStockDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> unload(List<Map<String, dynamic>> data) async {
    return await createRequest(
      path: '$_basePath/emptying',
      parser: voidParser(),
      body: data,
      successLog: 'Unload process completed',
    );
  }
}
