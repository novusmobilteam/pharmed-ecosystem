import '../../../../core/core.dart';
import '../model/cabin_fault_dto.dart';

abstract class CabinFaultDataSource {
  /// Bakım/Arıza kayıtlarını getiren servis
  Future<Result<List<CabinFaultDTO>>> getCabinFaultRecords();

  /// Arıza kaydı oluşturan servis
  Future<Result<void>> createFaultRecord(CabinFaultDTO dto, int slotId);

  /// Arıza kaydı temizleyen servis
  Future<Result<void>> clearFaultRecord(CabinFaultDTO dto, int slotId);

  /// Bakım kaydı oluşturan servis
  Future<Result<void>> createMaintenanceRecord(CabinFaultDTO dto, int slotId);

  /// Bakım kaydı temizleyen servis
  Future<Result<void>> clearMaintenanceRecord(CabinFaultDTO dto, int slotId);
}
