import '../../../../core/core.dart';

import '../../domain/entity/kit_content.dart';
import '../../domain/repository/i_kit_content_repository.dart';
import '../datasource/kit_content_datasource.dart';

class KitContentRepository implements IKitContentRepository {
  final KitContentDataSource _ds;

  KitContentRepository(this._ds);

  @override
  Future<Result<List<KitContent>>> getKitContent(int id, {bool forceRefresh = true}) async {
    final res = await _ds.getKitContent(id);
    return res.when(
      ok: (list) {
        final entities = (list).map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createKitContent(KitContent entity) async {
    return await _ds.createKitContent(entity.toDTO());
  }

  @override
  Future<Result<void>> updateKitContent(KitContent entity) async {
    return await _ds.updateKitContent(entity.toDTO());
  }

  @override
  Future<Result<void>> deleteKitContent(KitContent kit) async {
    return await _ds.deleteKitContent(kit.id!);
  }
}
