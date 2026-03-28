import '../../../../core/core.dart';
import '../../domain/entity/filling_list.dart';
import '../../domain/entity/filling_detail.dart';
import '../../../cabin/domain/entity/cabin_filling_request.dart';
import '../../../cabin_stock/domain/entity/cabin_stock.dart';
import '../../domain/repository/i_filling_list_repository.dart';
import '../datasource/filling_list_datasource.dart';

class FillingListRepository implements IFillingListRepository {
  final FillingListDataSource _ds;

  FillingListRepository(this._ds);

  @override
  Future<Result<List<FillingList>>> getFillingLists(int stationId) async {
    final r = await _ds.getFillingLists(stationId);
    return r.when(
      ok: (list) {
        final entities = list.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<List<CabinStock>>> getRefillCandidates({
    required FillingType type,
    required int stationId,
  }) async {
    final r = await _ds.getRefillCandidates(type: type, stationId: stationId);
    return r.when(
      ok: (list) {
        final entities = list.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<void>> cancelFillingList(int fillingListId, int stationId) async {
    return await _ds.cancelFillingList(fillingListId, stationId);
  }

  @override
  Future<Result<void>> updateFillingListStatus(int fillingListId, int stationId) async {
    return await _ds.updateFillingListStatus(fillingListId, stationId);
  }

  @override
  Future<Result<void>> createFillingList(
    List<Map<String, dynamic>> data, {
    required int stationId,
  }) async {
    final res = await _ds.createFillingList(data, stationId: stationId);

    return res.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateFillingList(
    List<Map<String, dynamic>> data, {
    required int stationId,
    required int fillingListId,
  }) async {
    final res = await _ds.updateFillingList(data, stationId: stationId, fillingListId: fillingListId);

    return res.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<FillingDetail>>> getFillingListDetail(int fillingListId) async {
    final res = await _ds.getFillingListDetail(fillingListId);

    return res.when(
      ok: (data) {
        final entites = data.map((d) => d.toEntity()).toList();
        return Result.ok(entites);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<FillingList>>> getCurrentStationFillingLists() async {
    final res = await _ds.getCurrentStationFillingLists();

    return res.when(
      ok: (data) {
        final entites = data.map((d) => d.toEntity()).toList();
        return Result.ok(entites);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> fill(List<CabinFillingRequest> data) async {
    return await _ds.fill(data);
  }
}
