import '../../../../core/core.dart';

import '../model/cabin_fault_dto.dart';
import 'cabin_fault_datasource.dart';

class CabinFaultLocalDataSource extends BaseLocalDataSource<CabinFaultDTO, int> implements CabinFaultDataSource {
  CabinFaultLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => CabinFaultDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => d.copyWith(id: id),
        );

  @override
  Future<Result<List<CabinFaultDTO>>> getCabinFaultRecords() async {
    return Result.ok([]);
  }

  @override
  Future<Result<void>> clearFaultRecord(CabinFaultDTO dto, int slotId) => createRequest(dto);

  @override
  Future<Result<void>> clearMaintenanceRecord(CabinFaultDTO dto, int slotId) => createRequest(dto);

  @override
  Future<Result<void>> createFaultRecord(CabinFaultDTO dto, int slotId) => createRequest(dto);

  @override
  Future<Result<void>> createMaintenanceRecord(CabinFaultDTO dto, int slotId) => createRequest(dto);
}
