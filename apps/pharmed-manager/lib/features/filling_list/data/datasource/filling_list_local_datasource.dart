import '../../../../core/core.dart';
import '../../../cabin/domain/entity/cabin_filling_request.dart';
import '../../../cabin_stock/data/model/cabin_stock_dto.dart';
import '../model/filling_list_dto.dart';
import '../model/filling_detail_dto.dart';
import 'filling_list_datasource.dart';

class _FillingListStore extends BaseLocalDataSource<FillingListDTO, int> {
  _FillingListStore({required super.filePath})
      : super(
          fromJson: (m) => FillingListDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => d.copyWith(id: id),
        );
}

class _FillingListDetailStore extends BaseLocalDataSource<FillingDetailDTO, int> {
  _FillingListDetailStore({required super.filePath})
      : super(
          fromJson: (m) => FillingDetailDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => d.copyWith(id: id),
        );
}

/// Dolum Listesi işlemleri için yerel (Mock) veri kaynağı.
class FillingListLocalDataSource implements FillingListDataSource {
  final _FillingListStore _recordStore;
  final _FillingListDetailStore _detailStore;

  FillingListLocalDataSource({
    required String recordsPath,
    required String detailsPath,
  })  : _recordStore = _FillingListStore(filePath: recordsPath),
        _detailStore = _FillingListDetailStore(filePath: detailsPath);

  @override
  Future<Result<List<FillingListDTO>>> getFillingLists(int stationId) async {
    return Result.ok([]);
  }

  @override
  Future<Result<List<CabinStockDTO>>> getRefillCandidates({
    required FillingType type,
    required int stationId,
  }) async {
    return Result.ok([]);
  }

  @override
  Future<Result<void>> cancelFillingList(int fillingListId, int stationId) async {
    return Result.ok(null);
  }

  @override
  Future<Result<void>> updateFillingListStatus(int fillingListId, int stationId) async {
    return Result.ok(null);
  }

  @override
  Future<Result<void>> createFillingList(
    List<Map<String, dynamic>> data, {
    required int stationId,
    int? fillingListId,
  }) async {
    return Result.ok(null);
  }

  @override
  Future<Result<void>> updateFillingList(
    List<Map<String, dynamic>> data, {
    required int stationId,
    required int fillingListId,
  }) async {
    return Result.ok(null);
  }

  @override
  Future<Result<List<FillingDetailDTO>>> getFillingListDetail(int fillingListId) async {
    final res = await _detailStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<FillingListDTO>>> getCurrentStationFillingLists() async {
    final res = await _recordStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> fill(List<CabinFillingRequest> data) async {
    return Result.ok(null);
  }
}
