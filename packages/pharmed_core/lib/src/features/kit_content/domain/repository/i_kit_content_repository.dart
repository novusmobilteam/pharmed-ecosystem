import 'package:pharmed_core/pharmed_core.dart';

abstract class IKitContentRepository {
  Future<Result<List<KitContent>>> getKitContent(int id);
  Future<Result<void>> createKitContent(KitContent entity);
  Future<Result<void>> updateKitContent(KitContent entity);
  Future<Result<void>> deleteKitContent(KitContent entity);
}
