import '../../../../core/core.dart';
import '../model/dosage_form_dto.dart';
import 'dosage_form_datasource.dart';

class DosageFormRemoteDataSource extends BaseRemoteDataSource implements DosageFormDataSource {
  final String _basePath = '/DosageForm';

  DosageFormRemoteDataSource({required super.apiManager});

  @override
  Future<Result<ApiResponse<List<DosageFormDTO>>>> getDosageForms({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<DosageFormDTO>>>(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(DosageFormDTO.fromJson),
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<DosageFormDTO?>> createDosageForm(DosageFormDTO dto) {
    return createRequest<DosageFormDTO>(
      path: _basePath,
      body: dto.toJson(),
      parser: singleParser(DosageFormDTO.fromJson),
    );
  }

  @override
  Future<Result<DosageFormDTO?>> updateDosageForm(DosageFormDTO dto) {
    return updateRequest<DosageFormDTO>(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: singleParser(DosageFormDTO.fromJson),
    );
  }

  @override
  Future<Result<void>> deleteDosageForm(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
    );
  }
}
