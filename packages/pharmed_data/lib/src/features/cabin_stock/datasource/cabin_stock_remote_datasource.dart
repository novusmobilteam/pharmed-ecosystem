// [SWREQ-DATA-CABINSTOCK-001]
// Sınıf: Class B
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/src/network/base_remote_datasource.dart';

class CabinStockRemoteDataSource extends BaseRemoteDataSource {
  CabinStockRemoteDataSource({required super.apiManager});

  static const _base = '/CabinDrawrStock';

  String get logSwreq => 'SWREQ-DATA-DRUGCLASS-001';

  String get logUnit => 'SW-UNIT-DRUGCLASS';

  /// Belirtilen kabindeki tüm materyal stoklarını çeker.
  Future<Result<List<CabinStockDTO>>> getStocks(int cabinId) async {
    final res = await fetchRequest<List<CabinStockDTO>>(
      path: '$_base/allMaterial/$cabinId',
      parser: BaseRemoteDataSource.listParser(CabinStockDTO.fromJson),
      successLog: 'Cabin Drawer Stocks fetched',
      emptyLog: 'No drawers found',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <CabinStockDTO>[]), error: Result.error);
  }

  /// Son kullanma tarihi yaklaşan (örneğin 14 gün) ürünleri sayfalı olarak getirir.

  Future<Result<List<CabinStockDTO>>> getExpiringStocks() async {
    final res = await fetchRequest<List<CabinStockDTO>>(
      path: '$_base/expirationDate/14',
      parser: BaseRemoteDataSource.listParser(CabinStockDTO.fromJson),
      successLog: 'Expiring materials fetched',
      emptyLog: 'No expiring materials found',
    );

    return res.when(ok: (data) => Result.ok(data ?? []), error: Result.error);
  }

  /// Tekil bir ilacın dolum/stok bilgisini getirir.
  Future<Result<CabinStockDTO?>> getMedicineInfo(int medicineId) async {
    final res = await fetchRequest<CabinStockDTO>(
      path: '$_base/materialInfo/$medicineId',
      parser: BaseRemoteDataSource.singleParser(CabinStockDTO.fromJson),
      successLog: 'Medicine info fetched',
    );

    return res.when(ok: (data) => Result.ok(data), error: Result.error);
  }

  /// Dolum isteğini sunucuya iletir.
  Future<Result<void>> fill(List<dynamic> data) async {
    return await createRequest(
      path: _base,
      parser: BaseRemoteDataSource.voidParser(),
      body: data.map((e) => e.toJson()).toList(),
      successLog: 'Filling process completed',
    );
  }

  /// Sayım sonucunu sunucuya iletir (Update/PATCH).
  Future<Result<void>> count(List<dynamic> data) async {
    return await updateRequest(
      path: '$_base/censusQuantity',
      parser: BaseRemoteDataSource.voidParser(),
      body: data.map((e) => e.toJson()).toList(),
      successLog: 'Census quantity updated',
    );
  }

  Future<Result<List<CabinStockDTO>>> getCurrentCabinStock() async {
    final res = await fetchRequest<List<CabinStockDTO>>(
      path: '$_base/currentStationStock',
      parser: BaseRemoteDataSource.listParser(CabinStockDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? []), error: Result.error);
  }

  Future<Result<List<CabinStockDTO>>> getExpiredStocks() async {
    final res = await fetchRequest<List<CabinStockDTO>>(
      path: '$_base/report/expiredMiadDate',
      parser: BaseRemoteDataSource.listParser(CabinStockDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? []), error: Result.error);
  }

  Future<Result<List<StationStockDTO>>> getStationStocks(int stationId) async {
    final res = await fetchRequest<List<StationStockDTO>>(
      path: '$_base/stock/$stationId',
      parser: BaseRemoteDataSource.listParser(StationStockDTO.fromJson),
      successLog: 'Station stocks fetched',
      emptyLog: 'No station stocks',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <StationStockDTO>[]), error: Result.error);
  }

  Future<Result<void>> unload(List<Map<String, dynamic>> data) async {
    return await createRequest(
      path: '$_base/emptying',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
      successLog: 'Unload process completed',
    );
  }
}
