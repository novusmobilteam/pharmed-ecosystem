import '../../../../core/core.dart';
import '../../domain/entity/warning.dart';
import '../datasource/warning_datasource.dart';
import '../../domain/repository/i_warning_repository.dart';

class WarningRepository implements IWarningRepository {
  final WarningDataSource _ds;

  WarningRepository(this._ds);

  @override
  Future<Result<List<Warning>>> getWarnings() async {
    final res = await _ds.getWarnings();
    return res.when(
      ok: (list) {
        final entities = list.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createWarning(Warning entity) async {
    final dto = entity.toDTO();
    return await _ds.createWarning(dto);
  }

  @override
  Future<Result<void>> updateWarning(Warning entity) async {
    final dto = entity.toDTO();
    return await _ds.updateWarning(dto);
  }

  @override
  Future<Result<void>> deleteWarning(Warning warning) async {
    final id = warning.id;
    if (id == null) return Result.error(CustomException(message: 'deleteWarning: id is null'));

    return await _ds.deleteWarning(id);
  }
}
