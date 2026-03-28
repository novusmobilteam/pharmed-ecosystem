import '../../../../core/core.dart';
import '../model/drug_type_dto.dart';
import 'drug_type_datasource.dart';

/// İlaç Türü işlemleri için uzak (API) veri kaynağı.
class DrugTypeRemoteDataSource extends BaseRemoteDataSource implements DrugTypeDataSource {
  final String _basePath = '/DrugType';

  DrugTypeRemoteDataSource({required super.apiManager});

  @override
  Future<Result<ApiResponse<List<DrugTypeDTO>>>> getDrugTypes({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<DrugTypeDTO>>>(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(DrugTypeDTO.fromJson),
      successLog: 'Drug types fetched',
      emptyLog: 'No drug types',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createDrugType(DrugTypeDTO dto) async {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Drug type created',
    );
  }

  @override
  Future<Result<void>> updateDrugType(DrugTypeDTO dto) {
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Drug type updated',
    );
  }

  @override
  Future<Result<void>> deleteDrugType(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Drug type deleted',
    );
  }
}
