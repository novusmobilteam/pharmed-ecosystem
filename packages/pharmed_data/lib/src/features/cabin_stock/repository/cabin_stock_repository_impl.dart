// [SWREQ-DATA-CABINSTOCK-002]
// ICabinAssignmentRepository implementasyonu.
// DTO → entity dönüşümü SttionMapper üzerinden yapılır.
// Sınıf: Class B
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class CabinStockRepository implements ICabinStockRepository {
  CabinStockRepository({
    required CabinStockRemoteDataSource dataSource,
    required CabinStockMapper cabinMapper,
    required StationStockMapper stationMapper,
  }) : _dataSource = dataSource,
       _cabinMapper = cabinMapper,
       _stationMapper = stationMapper;

  final CabinStockRemoteDataSource _dataSource;
  final CabinStockMapper _cabinMapper;
  final StationStockMapper _stationMapper;

  @override
  Future<Result<List<CabinStock>>> getStocks(int cabinId) async {
    final result = await _dataSource.getStocks(cabinId);
    return result.when(ok: (dtos) => Result.ok(_cabinMapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<CabinStock>>> getExpiringStocks() async {
    final result = await _dataSource.getExpiringStocks();
    return result.when(ok: (dtos) => Result.ok(_cabinMapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<CabinStock?>> getMedicineInfo(int medicineId) async {
    final result = await _dataSource.getMedicineInfo(medicineId);
    return result.when(ok: (dto) => Result.ok(_cabinMapper.toEntityOrNull(dto)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> fill(List<dynamic> data) async {
    return await _dataSource.fill(data);
  }

  @override
  Future<Result<void>> count(List<dynamic> data) async {
    return await _dataSource.count(data);
  }

  @override
  Future<Result<List<CabinStock>>> getCurrentCabinStock() async {
    final result = await _dataSource.getCurrentCabinStock();
    return result.when(ok: (dtos) => Result.ok(_cabinMapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<CabinStock>>> getExpiredStocks() async {
    final result = await _dataSource.getExpiredStocks();
    return result.when(ok: (dtos) => Result.ok(_cabinMapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<StationStock>>> getStationStocks(int stationId) async {
    final result = await _dataSource.getStationStocks(stationId);
    return result.when(ok: (dtos) => Result.ok(_stationMapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> unload(List<Map<String, dynamic>> data) async {
    return _dataSource.unload(data);
  }
}
