import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract class IKitRepository {
  Future<Result<ApiResponse<List<Kit>>>> getKits({int? skip, int? take, String? search});
  Future<Result<void>> createKit(Kit entity);
  Future<Result<void>> updateKit(Kit entity);
  Future<Result<void>> deleteKit(Kit entity);
}
