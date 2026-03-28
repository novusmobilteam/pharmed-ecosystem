import '../../../../core/core.dart';
import '../model/unit_dto.dart';

abstract class UnitDataSource {
  Future<Result<ApiResponse<List<UnitDTO>>>> getUnits({
    int? skip,
    int? take,
    String? search,
  });
  Future<Result<void>> createUnit(UnitDTO dto);
  Future<Result<void>> updateUnit(UnitDTO dto);
  Future<Result<void>> deleteUnit(int id);
}
