import '../../../../core/core.dart';
import '../model/kit_content_dto.dart';

abstract class KitContentDataSource {
  Future<Result<List<KitContentDTO>>> getKitContent(int kitId);
  Future<Result<void>> createKitContent(KitContentDTO dto);
  Future<Result<void>> updateKitContent(KitContentDTO dto);
  Future<Result<void>> deleteKitContent(int kitId);
}
