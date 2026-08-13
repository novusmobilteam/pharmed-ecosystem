import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RefillListRepositoryImpl implements IRefillListRepository {
  const RefillListRepositoryImpl({
    required RefillListRemoteDataSource dataSource,
    required RefillListMapper refillListMapper,
    required RefillListDetailMapper detailMapper,
    required CabinStockMapper cabinStockMapper,
  }) : _dataSource = dataSource,
       _refillListMapper = refillListMapper,
       _detailMapper = detailMapper,
       _cabinStockMapper = cabinStockMapper;

  final RefillListRemoteDataSource _dataSource;
  final RefillListMapper _refillListMapper;
  final RefillListDetailMapper _detailMapper;
  final CabinStockMapper _cabinStockMapper;

  @override
  Future<Result<List<RefillList>>> getFillingLists(int stationId) async {
    final res = await _dataSource.getFillingLists(stationId);
    return res.when(ok: (dtos) => Result.ok(_refillListMapper.toEntityList(dtos)), error: Result.error);
  }

  @override
  Future<Result<List<CabinStock>>> getRefillCandidates({required RefillType type, required int stationId}) async {
    final res = await _dataSource.getRefillCandidates(type: type, stationId: stationId);
    return res.when(ok: (dtos) => Result.ok(_cabinStockMapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> cancelFillingList(int fillingListId, int stationId) async {
    return await _dataSource.cancelFillingList(fillingListId, stationId);
  }

  @override
  Future<Result<void>> updateFillingListStatus(int fillingListId, int stationId) async {
    return await _dataSource.updateFillingListStatus(fillingListId, stationId);
  }

  @override
  Future<Result<void>> createFillingList(List<Map<String, dynamic>> data, {required int stationId}) async {
    return await _dataSource.createFillingList(data, stationId: stationId);
  }

  @override
  Future<Result<void>> updateFillingList(
    List<Map<String, dynamic>> data, {
    required int stationId,
    required int fillingListId,
  }) async {
    return await _dataSource.updateFillingList(data, stationId: stationId, fillingListId: fillingListId);
  }

  @override
  Future<Result<List<RefillListDetail>>> getFillingListDetail(int fillingListId) async {
    final res = await _dataSource.getFillingListDetail(fillingListId);
    return res.when(ok: (dtos) => Result.ok(_detailMapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<RefillList>>> getCurrentStationFillingLists() async {
    final res = await _dataSource.getCurrentStationFillingLists();
    return res.when(ok: (dtos) => Result.ok(_refillListMapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> fill(List<CabinRefillParams> data) async {
    return await _dataSource.fill(data);
  }
}
