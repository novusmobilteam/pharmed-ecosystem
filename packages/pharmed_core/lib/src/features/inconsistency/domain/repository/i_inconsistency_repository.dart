import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract class IInconsistencyRepository {
  /// Kabine göre tutarsızlık listesi
  Future<Result<ApiResponse<List<Inconsistency>>>> getInconsistencies(int stationId, {PagedQueryParams? params});
}
