// [SWREQ-DATA-DRUGTYPE-002]
// IFaultRepository implementasyonu.
// DTO → entity dönüşümü FaultMapper üzerinden yapılır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class FaultRepositoryImpl implements IFaultRepository {
  FaultRepositoryImpl({
    required FaultRemoteDataSource dataSource,
    required MasterFaultMapper masterFaultMapper,
    required MobileFaultMapper mobileFaultMapper,
  }) : _dataSource = dataSource,
       _masterFaultMapper = masterFaultMapper,
       _mobileFaultMapper = mobileFaultMapper;

  final FaultRemoteDataSource _dataSource;
  final MasterFaultMapper _masterFaultMapper;
  final MobileFaultMapper _mobileFaultMapper;

  @override
  Future<Result<List<MasterFault>>> getMasterCabinFaultRecords() async {
    final res = await _dataSource.getMasterCabinFaultRecords();
    return res.when(
      ok: (dtos) => Result.ok(_masterFaultMapper.toEntityList(dtos ?? [])),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<MobileFault>>> getMobileCabinFaultRecords() async {
    final res = await _dataSource.getMobileCabinFaultRecords();
    return res.when(
      ok: (dtos) => Result.ok(_mobileFaultMapper.toEntityList(dtos ?? [])),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createMasterCabinFaultRecord(MasterFault fault, int cellId) =>
      _dataSource.createMasterCabinFaultRecord(_masterFaultMapper.toDto(fault), cellId);

  @override
  Future<Result<void>> createMobilCabinFaultRecord(MobileFault fault, int slotId) =>
      _dataSource.createMobilCabinFaultRecord(_mobileFaultMapper.toDto(fault), slotId);

  @override
  Future<Result<void>> clearMasterCabinFaultRecord(MasterFault fault, int cellId) =>
      _dataSource.clearMasterCabinFaultRecord(_masterFaultMapper.toDto(fault), cellId);

  @override
  Future<Result<void>> clearMobilCabinFaultRecord(MobileFault fault, int slotId) =>
      _dataSource.clearMobilCabinFaultRecord(_mobileFaultMapper.toDto(fault), slotId);

  @override
  Future<Result<void>> createMasterCabinMaintenanceRecord(MasterFault fault, int cellId) =>
      _dataSource.createMasterCabinMaintenanceRecord(_masterFaultMapper.toDto(fault), cellId);

  @override
  Future<Result<void>> createMobilCabinMaintenanceRecord(MobileFault fault, int slotId) =>
      _dataSource.createMobilCabinMaintenanceRecord(_mobileFaultMapper.toDto(fault), slotId);

  @override
  Future<Result<void>> clearMasterCabinMaintenanceRecord(MasterFault fault, int slotId) =>
      _dataSource.clearMasterCabinMaintenanceRecord(_masterFaultMapper.toDto(fault), slotId);

  @override
  Future<Result<void>> clearMobilCabinMaintenanceRecord(MobileFault fault, int cellId) =>
      _dataSource.clearMobilCabinMaintenanceRecord(_mobileFaultMapper.toDto(fault), cellId);
}
