import '../../../../core/core.dart';
import '../model/drug_class_dto.dart';
import 'drug_class_datasource.dart';

/// İlaç Sınıfı işlemleri için uzak (API) veri kaynağı.
class DrugClassRemoteDataSource extends BaseRemoteDataSource implements DrugClassDataSource {
  final String _basePath = '/DrugClass';

  DrugClassRemoteDataSource({required super.apiManager});

  @override
  Future<Result<ApiResponse<List<DrugClassDTO>>>> getDrugClasses({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<DrugClassDTO>>>(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(DrugClassDTO.fromJson),
      successLog: 'Drug classes fetched',
      emptyLog: 'No drug classes',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createDrugClass(DrugClassDTO dto) {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Drug class created',
    );
  }

  @override
  Future<Result<void>> updateDrugClass(DrugClassDTO dto) {
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Drug class updated',
    );
  }

  @override
  Future<Result<void>> deleteDrugClassById(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Drug class deleted',
    );
  }
}
