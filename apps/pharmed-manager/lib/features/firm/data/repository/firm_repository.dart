import '../../../../core/core.dart';
import '../../domain/entity/firm.dart';
import '../../domain/repository/i_firm_repository.dart';
import '../datasource/firm_data_source.dart';

class FirmRepository implements IFirmRepository {
  final FirmDataSource _ds;

  FirmRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<Firm>>>> getFirms({int? skip, int? take, String? search}) async {
    final res = await _ds.getFirms(
      skip: skip,
      take: take,
    );
    return res.when(
      ok: (response) {
        List<Firm> entities = [];
        if (response.data != null) {
          entities = response.data!.map((d) => d.toEntity()).toList();
        }
        return Result.ok(ApiResponse<List<Firm>>(
          data: entities,
          statusCode: response.statusCode,
          isSuccess: response.isSuccess,
          totalCount: response.totalCount,
          groupCount: response.groupCount,
        ));
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<Firm>> createFirm(Firm entity) async {
    final dto = entity.toDto();
    final r = await _ds.createFirm(dto);

    return r.when(
      ok: (created) {
        final data = (created ?? dto).toEntity();
        return Result.ok(data);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateFirm(Firm entity) async {
    final dto = entity.toDto();
    final res = await _ds.updateFirm(dto);

    return res.when(
      ok: (updated) {
        return Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> deleteFirm(int id) async {
    final r = await _ds.deleteFirm(id);
    return r.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }
}
