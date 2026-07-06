// [SWREQ-DATA-CABINSTOCK-002]
// ICabinAssignmentRepository implementasyonu.
// DTO → entity dönüşümü SttionMapper üzerinden yapılır.
// Sınıf: Class B
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class CabinStockRepositoryImpl implements ICabinStockRepository {
  CabinStockRepositoryImpl({
    required CabinStockRemoteDataSource dataSource,
    required CabinStockLocalDataSource localDataSource,
    required CabinStockMapper cabinMapper,
    required StationStockMapper stationMapper,
    required CabinExpectedEpcMapper epcMapper,
  }) : _dataSource = dataSource,
       _local = localDataSource,
       _cabinMapper = cabinMapper,
       _stationMapper = stationMapper,
       _epcMapper = epcMapper;

  final CabinStockRemoteDataSource _dataSource;
  final CabinStockLocalDataSource _local;
  final CabinStockMapper _cabinMapper;
  final StationStockMapper _stationMapper;
  final CabinExpectedEpcMapper _epcMapper;

  @override
  Future<Result<List<CabinStock>>> getCurrentCabinStock() async {
    final result = await _dataSource.getCurrentCabinStock();

    return result.when(
      ok: (dtos) async {
        // Başarılı → cache'e yaz
        await _local.saveCurrentStock(dtos);
        return Result.ok(_cabinMapper.toEntityList(dtos));
      },
      error: (e) => Result.error(e),
    );
  }

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
  Future<Result<void>> refillMasterCabin(List<dynamic> data) async {
    return await _dataSource.refillMasterCabin(data);
  }

  @override
  Future<Result<void>> refillMobileCabin(List<dynamic> data) async {
    return await _dataSource.refillMobileCabin(data);
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
  Future<Result<void>> approveMissingStock(int prescriptionItemId) async {
    return await _dataSource.approveMissingStock(prescriptionItemId);
  }

  @override
  Future<Result<void>> rejectMissingStock(int prescriptionItemId) async {
    return await _dataSource.rejectMissingStock(prescriptionItemId);
  }

  @override
  Future<Result<List<CabinExpectedEpc>>> getExpectedEpcs(int cabinId) async {
    final result = await _dataSource.getExpectedEpcs(cabinId);
    return result.when(ok: (dtos) => Result.ok(_epcMapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> reportExcessStock({
    required Map<String, dynamic> data,
    required int cabinInventoryTypeId,
  }) async {
    return await _dataSource.reportExcessStock(data: data, cabinInventoryTypeId: cabinInventoryTypeId);
  }

  @override
  Future<Result<void>> reportMissingStock({required int prescriptionItemId, required int cabinInventoryTypeId}) async {
    return await _dataSource.reportMissingStock(
      prescriptionItemId: prescriptionItemId,
      cabinInventoryTypeId: cabinInventoryTypeId,
    );
  }
}
