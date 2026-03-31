import '../../../../core/core.dart';
import '../model/cabin_fault_dto.dart';

import 'cabin_fault_datasource.dart';

class CabinFaultRemoteDataSource extends BaseRemoteDataSource implements CabinFaultDataSource {
  CabinFaultRemoteDataSource({required super.apiManager});

  final String _basePath = '/DrawrMaintenanceMalfunction';

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();

  @override
  Future<Result<List<CabinFaultDTO>>> getCabinFaultRecords() async {
    final res = await fetchRequest<List<CabinFaultDTO>>(
      path: _basePath,
      parser: BaseRemoteDataSource.listParser(CabinFaultDTO.fromJson),
      successLog: 'Cabin fault records fetched',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <CabinFaultDTO>[]), error: Result.error);
  }

  @override
  Future<Result<void>> clearFaultRecord(CabinFaultDTO dto, int slotId) async {
    return await updateRequest(path: '$_basePath/notFaulty/$slotId', parser: BaseRemoteDataSource.voidParser());
  }

  @override
  Future<Result<void>> clearMaintenanceRecord(CabinFaultDTO dto, int slotId) async {
    return await updateRequest(path: '$_basePath/notMaintenance/$slotId', parser: BaseRemoteDataSource.voidParser());
  }

  @override
  Future<Result<void>> createFaultRecord(CabinFaultDTO dto, int slotId) async {
    return await updateRequest(path: '$_basePath/faulty/$slotId', parser: BaseRemoteDataSource.voidParser());
  }

  @override
  Future<Result<void>> createMaintenanceRecord(CabinFaultDTO dto, int slotId) async {
    return await updateRequest(path: '$_basePath/maintenance/$slotId', parser: BaseRemoteDataSource.voidParser());
  }
}
