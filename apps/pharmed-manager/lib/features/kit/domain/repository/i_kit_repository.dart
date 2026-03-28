import '../../../../core/core.dart';
import '../entity/kit.dart';

abstract class IKitRepository {
  Future<Result<List<Kit>>> getKits();
  Future<Result<void>> createKit(Kit entity);
  Future<Result<void>> updateKit(Kit entity);
  Future<Result<void>> deleteKit(Kit entity);
}
