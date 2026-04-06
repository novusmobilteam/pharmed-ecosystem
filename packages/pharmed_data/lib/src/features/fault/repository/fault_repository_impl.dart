// [SWREQ-DATA-DRUGTYPE-002]
// IFaultRepository implementasyonu.
// DTO → entity dönüşümü FaultMapper üzerinden yapılır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class FaultRepositoryImpl implements IFaultRepository {
  FaultRepositoryImpl({required FaultRemoteDataSource dataSource, required FaultMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final FaultRemoteDataSource _dataSource;
  final FaultMapper _mapper;

  @override
  Future<Result<List<Fault>>> getCabinFaultRecords() async {
    final res = await _dataSource.getCabinFaultRecords();
    return res.when(ok: (dtos) => Result.ok(_mapper.toEntityList(dtos ?? [])), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> clearFaultRecord(Fault fault, int slotId) =>
      _dataSource.clearFaultRecord(_mapper.toDto(fault), slotId);

  @override
  Future<Result<void>> clearMaintenanceRecord(Fault fault, int slotId) =>
      _dataSource.clearMaintenanceRecord(_mapper.toDto(fault), slotId);

  @override
  Future<Result<void>> createFaultRecord(Fault fault, int slotId) =>
      _dataSource.createFaultRecord(_mapper.toDto(fault), slotId);

  @override
  Future<Result<void>> createMaintenanceRecord(Fault fault, int slotId) =>
      _dataSource.createMaintenanceRecord(_mapper.toDto(fault), slotId);
}
