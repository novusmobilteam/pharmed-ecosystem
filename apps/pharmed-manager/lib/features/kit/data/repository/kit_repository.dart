import '../../../../core/core.dart';
import '../../domain/entity/kit.dart';
import '../../domain/repository/i_kit_repository.dart';
import '../datasource/kit_datasource.dart';

class KitRepository implements IKitRepository {
  final KitDataSource _ds;

  KitRepository(this._ds);

  @override
  Future<Result<List<Kit>>> getKits() async {
    final res = await _ds.getKits();
    return res.when(
      ok: (list) {
        final entities = (list).map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<void>> createKit(Kit entity) async {
    return await _ds.createKit(entity.toDto());
  }

  @override
  Future<Result<void>> updateKit(Kit entity) async {
    return await _ds.updateKit(entity.toDto());
  }

  @override
  Future<Result<void>> deleteKit(Kit kit) async {
    return await _ds.deleteKit(kit.id!);
  }
}
