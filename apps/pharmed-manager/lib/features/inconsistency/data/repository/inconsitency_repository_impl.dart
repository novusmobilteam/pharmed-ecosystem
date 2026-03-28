import '../../../../core/core.dart';
import '../../domain/entity/inconsistency.dart';
import '../datasource/inconsistency_datasource.dart';
import 'inconsistency_repository.dart';

class InconsistencyRepository implements IInconsistencyRepository {
  final InconsistencyDataSource _ds;

  InconsistencyRepository._(this._ds);

  /// Production
  factory InconsistencyRepository.prod({required InconsistencyDataSource remote}) => InconsistencyRepository._(remote);

  /// Development (lokal JSON vs.)
  factory InconsistencyRepository.dev({required InconsistencyDataSource local}) => InconsistencyRepository._(local);

  @override
  Future<Result<ApiResponse<List<Inconsistency>>>> getInconsistencies({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await _ds.getInconsistencies();
    return res.when(
      ok: (response) {
        List<Inconsistency> entities = [];
        if (response.data != null) {
          entities = response.data!.map((d) => d.toEntity()).toList();
        }
        return Result.ok(ApiResponse<List<Inconsistency>>(
          data: entities,
          statusCode: response.statusCode,
          isSuccess: response.isSuccess,
          totalCount: response.totalCount,
          groupCount: response.groupCount,
        ));
      },
      error: (e) => Result.error(e),
    );
  }
}
