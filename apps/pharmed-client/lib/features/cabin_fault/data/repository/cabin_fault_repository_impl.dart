// [SWREQ-DATA-CABINFAULT-002]
// ICabinAssignmentRepository implementasyonu.
// DTO → entity dönüşümü SttionMapper üzerinden yapılır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

import '../../domain/mapper/cabin_fault_mapper.dart';
import '../../domain/model/cabin_fault.dart';
import '../../domain/repository/i_cabin_fault_repository.dart';
import '../datasource/cabin_fault_remote_datasource.dart';

class CabinFaultRepository implements ICabinFaultRepository {
  CabinFaultRepository({required CabinFaultRemoteDataSource dataSource, required CabinFaultMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final CabinFaultRemoteDataSource _dataSource;
  final CabinFaultMapper _mapper;

  @override
  Future<Result<List<CabinFault>>> getCabinFaultRecords() async {
    final reseult = await _dataSource.getCabinFaultRecords();
    return reseult.when(ok: (dtos) => Result.ok(_mapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> clearFaultRecord(CabinFault fault, int slotId) =>
      _dataSource.clearFaultRecord(_mapper.toDto(fault), slotId);

  @override
  Future<Result<void>> clearMaintenanceRecord(CabinFault fault, int slotId) =>
      _dataSource.clearMaintenanceRecord(_mapper.toDto(fault), slotId);

  @override
  Future<Result<void>> createFaultRecord(CabinFault fault, int slotId) =>
      _dataSource.createFaultRecord(_mapper.toDto(fault), slotId);

  @override
  Future<Result<void>> createMaintenanceRecord(CabinFault fault, int slotId) =>
      _dataSource.createMaintenanceRecord(_mapper.toDto(fault), slotId);
}
