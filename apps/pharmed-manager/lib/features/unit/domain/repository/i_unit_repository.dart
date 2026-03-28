import '../../../../core/core.dart';
import '../entity/unit.dart';

abstract class IUnitRepository {
  Future<Result<ApiResponse<List<Unit>>>> getUnits({
    int? skip,
    int? take,
    String? search,
  });

  Future<Result<void>> createUnit(Unit entity);
  Future<Result<void>> updateUnit(Unit entity);
  Future<Result<void>> deleteUnit(Unit entity);
}
