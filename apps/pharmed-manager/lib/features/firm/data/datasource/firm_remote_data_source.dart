import '../../../../core/core.dart';
import '../model/firm_dto.dart';
import 'firm_data_source.dart';

class FirmRemoteDataSource extends BaseRemoteDataSource implements FirmDataSource {
  FirmRemoteDataSource({required super.apiManager});

  static const String _basePath = '/Firm';

  @override
  Future<Result<ApiResponse<List<FirmDTO>>>> getFirms({int? skip, int? take, String? search}) async {
    final res = await fetchRequest(
      path: _basePath,
      skip: skip,
      take: take,
      searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(FirmDTO.fromJson),
      successLog: 'Firms fetched',
      emptyLog: 'No firms',
    );
    return res.when(
      ok: (response) => Result.ok(response ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<FirmDTO?>> createFirm(FirmDTO firm) {
    return createRequest<FirmDTO?>(
      path: _basePath,
      body: firm.toJson(),
      parser: singleParser(FirmDTO.fromJson),
      successLog: 'Firm created',
    );
  }

  @override
  Future<Result<void>> updateFirm(FirmDTO firm) {
    return updateRequest(
      path: '$_basePath/${firm.id}',
      body: firm.toJson(),
      parser: voidParser(),
      successLog: 'Firm updated',
    );
  }

  @override
  Future<Result<void>> deleteFirm(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Firm deleted',
    );
  }
}
