import '../../../../core/core.dart';
import '../model/cabin_fault_dto.dart';

import 'cabin_fault_datasource.dart';

class CabinFaultRemoteDataSource extends BaseRemoteDataSource implements CabinFaultDataSource {
  CabinFaultRemoteDataSource({required super.apiManager});

  final String _basePath = '/DrawrMaintenanceMalfunction';

  @override
  Future<Result<List<CabinFaultDTO>>> getCabinFaultRecords() async {
    final res = await fetchRequest<List<CabinFaultDTO>>(
      path: _basePath,
      parser: listParser(CabinFaultDTO.fromJson),
      successLog: 'Cabin fault records fetched',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const <CabinFaultDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> clearFaultRecord(CabinFaultDTO dto, int slotId) async {
    return await updateRequest(
      path: '$_basePath/notFaulty/$slotId',
      parser: voidParser(),
    );
  }

  @override
  Future<Result<void>> clearMaintenanceRecord(CabinFaultDTO dto, int slotId) async {
    return await updateRequest(
      path: '$_basePath/notMaintenance/$slotId',
      parser: voidParser(),
    );
  }

  @override
  Future<Result<void>> createFaultRecord(CabinFaultDTO dto, int slotId) async {
    return await updateRequest(
      path: '$_basePath/faulty/$slotId',
      parser: voidParser(),
    );
  }

  @override
  Future<Result<void>> createMaintenanceRecord(CabinFaultDTO dto, int slotId) async {
    return await updateRequest(
      path: '$_basePath/maintenance/$slotId',
      parser: voidParser(),
    );
  }
}
