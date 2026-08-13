import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RefillListRemoteDataSource extends BaseRemoteDataSource {
  RefillListRemoteDataSource({required super.apiManager});

  final String _basePath = '/FiilingList';

  @override
  String get logSwreq => 'SWREQ-DATA-FILLINGLIST-001';

  @override
  String get logUnit => 'SW-UNIT-FILLINGLIST';

  Future<Result<List<RefillListDto>>> getFillingLists(int stationId) async {
    final res = await fetchRequest<List<RefillListDto>>(
      path: '$_basePath/master/$stationId',
      parser: BaseRemoteDataSource.listParser(RefillListDto.fromJson),
      successLog: 'Refill records fetched',
      emptyLog: 'No refill records',
    );

    return res.when(ok: (data) => Result.ok(data ?? []), error: Result.error);
  }

  Future<Result<List<CabinStockDTO>>> getRefillCandidates({required RefillType type, required int stationId}) async {
    final res = await fetchRequest<List<CabinStockDTO>>(
      path: '$_basePath/decreasingQuantityMaterial',
      parser: BaseRemoteDataSource.listParser(CabinStockDTO.fromJson),
      successLog: 'Refill record detail fetched',
      emptyLog: 'No refill record detail',
      query: {"typeId": type.id, "stationId": stationId},
    );

    return res.when(ok: (data) => Result.ok(data ?? const <CabinStockDTO>[]), error: Result.error);
  }

  Future<Result<void>> cancelFillingList(int fillingListId, int stationId) {
    return postRequest(
      path: '$_basePath/cancel/$fillingListId',
      parser: BaseRemoteDataSource.voidParser(),
      body: {"stationId": stationId, "id": fillingListId},
    );
  }

  Future<Result<void>> updateFillingListStatus(int fillingListId, int stationId) {
    return putRequest(
      path: '$_basePath/status/$fillingListId',
      parser: BaseRemoteDataSource.voidParser(),
      body: {"stationId": stationId, "id": fillingListId},
    );
  }

  Future<Result<void>> createFillingList(List<Map<String, dynamic>> data, {required int stationId}) {
    return postRequest(
      path: '$_basePath/detail/create/$stationId',
      body: data,
      parser: BaseRemoteDataSource.voidParser(),
    );
  }

  Future<Result<void>> updateFillingList(
    List<Map<String, dynamic>> data, {
    required int stationId,
    required int fillingListId,
  }) {
    return putRequest(
      path: '$_basePath/$fillingListId/detail/edit/$stationId',
      body: data,
      parser: BaseRemoteDataSource.voidParser(),
    );
  }

  Future<Result<List<RefillListDetailDto>>> getFillingListDetail(int fillingListId) async {
    final res = await fetchRequest<List<RefillListDetailDto>>(
      path: '$_basePath/detail/$fillingListId',
      parser: BaseRemoteDataSource.listParser(RefillListDetailDto.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <RefillListDetailDto>[]), error: Result.error);
  }

  Future<Result<List<RefillListDto>>> getCurrentStationFillingLists() async {
    final res = await fetchRequest<List<RefillListDto>>(
      path: '$_basePath/masterCurrentStation',
      parser: BaseRemoteDataSource.listParser(RefillListDto.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <RefillListDto>[]), error: Result.error);
  }

  Future<Result<void>> fill(List<CabinRefillParams> data) async {
    return await postRequest(
      path: '$_basePath/fiilingDetail/fill',
      parser: BaseRemoteDataSource.voidParser(),
      body: data.map((e) => e.toJson()).toList(),
    );
  }
}
