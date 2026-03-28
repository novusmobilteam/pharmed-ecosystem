import '../../../../core/core.dart';
import '../../domain/entity/inconsistency.dart';

abstract class IInconsistencyRepository {
  /// Kabine göre tutarsızlık listesi
  Future<Result<ApiResponse<List<Inconsistency>>>> getInconsistencies({
    int? skip,
    int? take,
    String? search,
  });

  // /// Bir tutarsızlık kaydının hareket/detay listesi
  // Future<Result<InconsistencyDetail?>> getInconsistencyDetail({
  //   required int id,
  //   bool forceRefresh = true,
  // });
}
