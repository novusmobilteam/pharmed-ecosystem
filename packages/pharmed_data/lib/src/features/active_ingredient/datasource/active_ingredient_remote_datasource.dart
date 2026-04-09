// [SWREQ-DATA-INGREDIENT-001]
// Sınıf: Class B
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class ActiveIngredientRemoteDataSource extends BaseRemoteDataSource {
  ActiveIngredientRemoteDataSource({required super.apiManager});

  final String _base = '/ActiveIngredient';

  @override
  String get logSwreq => 'SWREQ-DATA-INGREDIENT-001';

  @override
  String get logUnit => 'SW-UNIT-INGREDIENT';

  Future<Result<ApiResponse<List<ActiveIngredientDTO>>?>> getActiveIngredients({
    int? skip,
    int? take,
    String? search,
  }) async {
    return fetchRequest<ApiResponse<List<ActiveIngredientDTO>>>(
      path: _base,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(ActiveIngredientDTO.fromJson),
      successLog: 'Active ingredients fetched successfully',
      emptyLog: 'No active ingredients found',
    );
  }

  Future<Result<void>> createActiveIngredient(ActiveIngredientDTO dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Etken madde oluşturuldu',
    );
  }

  Future<Result<void>> updateActiveIngredient(ActiveIngredientDTO dto) {
    return updateRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Etken madde güncellendi',
    );
  }

  Future<Result<void>> deleteActiveIngredient(int id) {
    return deleteRequest(
      path: '$_base/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Etken madde silindi',
    );
  }
}
