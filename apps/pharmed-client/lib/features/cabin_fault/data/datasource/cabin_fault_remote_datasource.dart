import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../dto/cabin_fault_dto.dart';

// [SWREQ-DATA-CABINFAULT-001]
// Sınıf: Class B
class CabinFaultRemoteDataSource extends BaseRemoteDataSource {
  final String _base = '/DrawrMaintenanceMalfunction';

  @override
  String get logSwreq => 'SWREQ-DATA-CABINFAULT-001';

  @override
  String get logUnit => 'SW-UNIT-CABINFAULT';

  CabinFaultRemoteDataSource({required super.apiManager});

  Future<Result<List<CabinFaultDTO>>> getCabinFaultRecords() async {
    final res = await fetchRequest<List<CabinFaultDTO>>(
      path: _base,
      parser: BaseRemoteDataSource.listParser(CabinFaultDTO.fromJson),
      successLog: 'Cabin fault records fetched',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <CabinFaultDTO>[]), error: Result.error);
  }

  Future<Result<void>> clearFaultRecord(CabinFaultDTO dto, int slotId) async {
    return await updateRequest(path: '$_base/notFaulty/$slotId', parser: BaseRemoteDataSource.voidParser());
  }

  Future<Result<void>> clearMaintenanceRecord(CabinFaultDTO dto, int slotId) async {
    return await updateRequest(path: '$_base/notMaintenance/$slotId', parser: BaseRemoteDataSource.voidParser());
  }

  Future<Result<void>> createFaultRecord(CabinFaultDTO dto, int slotId) async {
    return await updateRequest(path: '$_base/faulty/$slotId', parser: BaseRemoteDataSource.voidParser());
  }

  Future<Result<void>> createMaintenanceRecord(CabinFaultDTO dto, int slotId) async {
    return await updateRequest(path: '$_base/maintenance/$slotId', parser: BaseRemoteDataSource.voidParser());
  }
}
