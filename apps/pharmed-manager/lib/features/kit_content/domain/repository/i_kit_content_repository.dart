import '../../../../core/core.dart';

import '../entity/kit_content.dart';

abstract class IKitContentRepository {
  Future<Result<List<KitContent>>> getKitContent(int id);
  Future<Result<void>> createKitContent(KitContent entity);
  Future<Result<void>> updateKitContent(KitContent entity);
  Future<Result<void>> deleteKitContent(KitContent entity);
}
