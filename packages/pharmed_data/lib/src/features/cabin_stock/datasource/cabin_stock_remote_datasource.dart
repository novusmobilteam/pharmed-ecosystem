// [SWREQ-DATA-CABINSTOCK-001]
// Sınıf: Class B
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/src/network/base_remote_datasource.dart';

class CabinStockRemoteDataSource extends BaseRemoteDataSource {
  CabinStockRemoteDataSource({required super.apiManager});

  static const _base = '/CabinDrawrStock';

  @override
  String get logSwreq => 'SWREQ-DATA-CABINSTOCK-001';

  @override
  String get logUnit => 'SW-UNIT-CABINSTOCK';

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

  /// Master kabin dolum işlemi
  Future<Result<void>> refillMasterCabin(List<dynamic> data) async {
    return await postRequest(
      path: _base,
      parser: BaseRemoteDataSource.voidParser(),
      body: data.map((e) => e.toJson()).toList(),
      successLog: 'Filling process completed',
    );
  }

  /// Mobil kabin dolum işlemi
  Future<Result<void>> refillMobileCabin(List<dynamic> data) async {
    //return Result.error(CustomException(message: 'message'));
    return await postRequest(
      path: '$_base/mobileCabin',
      parser: BaseRemoteDataSource.voidParser(),
      body: data.map((e) => e.toJson()).toList(),
      successLog: 'Filling process completed',
    );
  }

  Future<Result<List<CabinStockDTO>>> getCurrentCabinStock() async {
    final res = await fetchRequest<List<CabinStockDTO>>(
      path: '$_base/currentStationStock',
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

  Future<Result<void>> reportMissingStock({required int prescriptionItemId, required int cabinInventoryTypeId}) async {
    return await postRequest(
      path: '/CabinDrawrStock/mobileStockShortageReported/$prescriptionItemId',
      query: {'stockNotificationType': cabinInventoryTypeId},
      parser: BaseRemoteDataSource.voidParser(),
    );
  }

  Future<Result<void>> reportExcessStock({
    required Map<String, dynamic> data,
    required int cabinInventoryTypeId,
  }) async {
    return await postRequest(
      path: '/CabinDrawrStock/mobileExcessStockReported',
      body: data,
      query: {'stockNotificationType': cabinInventoryTypeId},
      parser: BaseRemoteDataSource.voidParser(),
    );
  }

  Future<Result<void>> approveMissingStock(int prescriptionItemId) async {
    final res = await postRequest(
      path: '$_base/mobileStockShortageReportedApprove/$prescriptionItemId',
      parser: BaseRemoteDataSource.voidParser(),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <StationStockDTO>[]), error: Result.error);
  }

  Future<Result<void>> rejectMissingStock(int prescriptionItemId) async {
    final res = await postRequest(
      path: '$_base/mobileStockShortageReportedReject/$prescriptionItemId',
      parser: BaseRemoteDataSource.voidParser(),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <StationStockDTO>[]), error: Result.error);
  }

  /// GET /CabinDrawrStockRfidTag?cabinId={id}
  ///
  /// Response: { statusCode, isSuccess, data: List<String> }
  Future<Result<List<CabinExpectedEpcDto>>> getExpectedEpcs(int cabinId) async {
    final res = await fetchRequest<List<CabinExpectedEpcDto>>(
      path: '/CabinDrawrStockRfidTag/$cabinId',
      parser: BaseRemoteDataSource.listParser(CabinExpectedEpcDto.fromJson),
      successLog: 'Station stocks fetched',
      emptyLog: 'No station stocks',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <CabinExpectedEpcDto>[]), error: Result.error);
  }
}
