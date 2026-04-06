import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-FAULT-001]
// Sınıf: Class B
class FaultRemoteDataSource extends BaseRemoteDataSource {
  FaultRemoteDataSource({required super.apiManager});

  final String _base = '/DrawrMaintenanceMalfunction';

  @override
  String get logSwreq => 'SWREQ-DATA-FAULT-001';

  @override
  String get logUnit => 'SW-UNIT-FAULT';

  Future<Result<List<FaultDto>?>> getCabinFaultRecords() async {
    return await fetchRequest<List<FaultDto>>(
      path: _base,
      parser: BaseRemoteDataSource.listParser(FaultDto.fromJson),
      successLog: 'Cabin fault records fetched',
    );
  }

  Future<Result<void>> clearFaultRecord(FaultDto dto, int slotId) async {
    return await updateRequest(path: '$_base/notFaulty/$slotId', parser: BaseRemoteDataSource.voidParser());
  }

  Future<Result<void>> clearMaintenanceRecord(FaultDto dto, int slotId) async {
    return await updateRequest(path: '$_base/notMaintenance/$slotId', parser: BaseRemoteDataSource.voidParser());
  }

  Future<Result<void>> createFaultRecord(FaultDto dto, int slotId) async {
    return await updateRequest(path: '$_base/faulty/$slotId', parser: BaseRemoteDataSource.voidParser());
  }

  Future<Result<void>> createMaintenanceRecord(FaultDto dto, int slotId) async {
    return await updateRequest(path: '$_base/maintenance/$slotId', parser: BaseRemoteDataSource.voidParser());
  }
}
