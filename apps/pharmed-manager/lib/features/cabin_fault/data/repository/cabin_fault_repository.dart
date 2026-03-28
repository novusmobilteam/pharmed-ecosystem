import '../../../../core/core.dart';
import '../../domain/entity/cabin_fault.dart';

import '../../domain/repository/i_cabin_fault_repository.dart';
import '../datasource/cabin_fault_datasource.dart';

class CabinFaultRepository implements ICabinFaultRepository {
  final CabinFaultDataSource _ds;

  CabinFaultRepository(this._ds);

  @override
  Future<Result<List<CabinFault>>> getCabinFaultRecords() async {
    final res = await _ds.getCabinFaultRecords();
    return res.when(
      ok: (data) {
        List<CabinFault> entities = [];
        entities = data.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> clearFaultRecord(CabinFault fault, int slotId) => _ds.clearFaultRecord(fault.toDTO(), slotId);

  @override
  Future<Result<void>> clearMaintenanceRecord(CabinFault fault, int slotId) =>
      _ds.clearMaintenanceRecord(fault.toDTO(), slotId);

  @override
  Future<Result<void>> createFaultRecord(CabinFault fault, int slotId) => _ds.createFaultRecord(fault.toDTO(), slotId);

  @override
  Future<Result<void>> createMaintenanceRecord(CabinFault fault, int slotId) =>
      _ds.createMaintenanceRecord(fault.toDTO(), slotId);
}
