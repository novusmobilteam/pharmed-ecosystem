import '../../../../core/core.dart';
import '../model/inconsistency_dto.dart';

abstract class InconsistencyDataSource {
  Future<Result<ApiResponse<List<InconsistencyDTO>>>> getInconsistencies();
}
