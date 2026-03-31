import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../../unit.dart';

abstract class IUnitRepository {
  Future<Result<ApiResponse<List<Unit>>>> getUnits({int? skip, int? take, String? search});

  Future<Result<void>> createUnit(Unit entity);
  Future<Result<void>> updateUnit(Unit entity);
  Future<Result<void>> deleteUnit(Unit entity);
}
