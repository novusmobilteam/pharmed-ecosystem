import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class InconsistencyRepositoryImpl implements IInconsistencyRepository {
  final InconsistencyRemoteDataSource _dataSource;
  final InconsistencyMapper _mapper;

  InconsistencyRepositoryImpl({required InconsistencyRemoteDataSource dataSource, required InconsistencyMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  @override
  Future<Result<ApiResponse<List<Inconsistency>>>> getInconsistencies({int? skip, int? take, String? search}) async {
    final res = await _dataSource.getInconsistencies();
    return res.when(
      ok: (response) {
        List<Inconsistency> entities = [];
        if (response.data != null) {
          entities = response.data!.map((d) => _mapper.toEntity(d)).toList();
        }
        return Result.ok(
          ApiResponse<List<Inconsistency>>(
            data: entities,
            statusCode: response.statusCode,
            isSuccess: response.isSuccess,
            totalCount: response.totalCount,
            groupCount: response.groupCount,
          ),
        );
      },
      error: (e) => Result.error(e),
    );
  }
}
