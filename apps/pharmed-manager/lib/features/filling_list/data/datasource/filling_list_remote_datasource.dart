import '../../../../core/core.dart';
import '../../../cabin/domain/entity/cabin_filling_request.dart';
import '../model/filling_list_dto.dart';
import '../model/filling_detail_dto.dart';
import 'filling_list_datasource.dart';

class FillingListRemoteDataSource extends BaseRemoteDataSource implements FillingListDataSource {
  FillingListRemoteDataSource({required super.apiManager});

  final String _basePath = '/FiilingList';

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();

  @override
  Future<Result<List<FillingListDTO>>> getFillingLists(int stationId) async {
    final res = await fetchRequest<List<FillingListDTO>>(
      path: '$_basePath/master/$stationId',
      parser: BaseRemoteDataSource.listParser(FillingListDTO.fromJson),
      successLog: 'Refill records fetched',
      emptyLog: 'No refill records',
    );

    return res.when(ok: (data) => Result.ok(data ?? []), error: Result.error);
  }

  @override
  Future<Result<List<CabinStockDTO>>> getRefillCandidates({required FillingType type, required int stationId}) async {
    final res = await fetchRequest<List<CabinStockDTO>>(
      path: '$_basePath/decreasingQuantityMaterial/',
      parser: BaseRemoteDataSource.listParser(CabinStockDTO.fromJson),
      successLog: 'Refill record detail fetched',
      emptyLog: 'No refill record detail',
      query: {"typeId": type.id, "stationId": stationId},
    );

    return res.when(ok: (data) => Result.ok(data ?? const <CabinStockDTO>[]), error: Result.error);
  }

  @override
  Future<Result<void>> cancelFillingList(int fillingListId, int stationId) {
    return createRequest(
      path: '$_basePath/cancel/$fillingListId',
      parser: BaseRemoteDataSource.voidParser(),
      body: {"stationId": stationId, "id": fillingListId},
    );
  }

  @override
  Future<Result<void>> updateFillingListStatus(int fillingListId, int stationId) {
    return updateRequest(
      path: '$_basePath/status/$fillingListId',
      parser: BaseRemoteDataSource.voidParser(),
      body: {"stationId": stationId, "id": fillingListId},
    );
  }

  @override
  Future<Result<void>> createFillingList(List<Map<String, dynamic>> data, {required int stationId}) {
    return createRequest(
      path: '$_basePath/detail/create/$stationId',
      body: data,
      parser: BaseRemoteDataSource.voidParser(),
    );
  }

  @override
  Future<Result<void>> updateFillingList(
    List<Map<String, dynamic>> data, {
    required int stationId,
    required int fillingListId,
  }) {
    return updateRequest(
      path: '$_basePath/$fillingListId/detail/edit/$stationId',
      body: data,
      parser: BaseRemoteDataSource.voidParser(),
    );
  }

  @override
  Future<Result<List<FillingDetailDTO>>> getFillingListDetail(int fillingListId) async {
    final res = await fetchRequest<List<FillingDetailDTO>>(
      path: '$_basePath/detail/$fillingListId',
      parser: BaseRemoteDataSource.listParser(FillingDetailDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <FillingDetailDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<FillingListDTO>>> getCurrentStationFillingLists() async {
    final res = await fetchRequest<List<FillingListDTO>>(
      path: '$_basePath/masterCurrentStation',
      parser: BaseRemoteDataSource.listParser(FillingListDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <FillingListDTO>[]), error: Result.error);
  }

  @override
  Future<Result<void>> fill(List<CabinFillingRequest> data) async {
    return await createRequest(
      path: '$_basePath/fiilingDetail/fill',
      parser: BaseRemoteDataSource.voidParser(),
      body: data.map((e) => e.toJson()).toList(),
    );
  }
}
