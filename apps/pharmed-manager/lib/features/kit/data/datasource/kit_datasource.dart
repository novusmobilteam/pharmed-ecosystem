import '../../../../core/core.dart';
import '../model/kit_dto.dart';

abstract class KitDataSource {
  Future<Result<List<KitDTO>>> getKits();
  Future<Result<void>> createKit(KitDTO dto);
  Future<Result<void>> updateKit(KitDTO dto);
  Future<Result<void>> deleteKit(int id);
}
