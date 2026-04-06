import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IFaultRepository {
  /// Bakım/Arıza kayıtlarını getiren servis
  Future<Result<List<Fault>>> getCabinFaultRecords();

  /// Arıza kaydı oluşturan servis
  Future<Result<void>> createFaultRecord(Fault fault, int slotId);

  /// Arıza kaydı temizleyen servis
  Future<Result<void>> clearFaultRecord(Fault fault, int slotId);

  /// Bakım kaydı oluşturan servis
  Future<Result<void>> createMaintenanceRecord(Fault fault, int slotId);

  /// Bakım kaydı temizleyen servis
  Future<Result<void>> clearMaintenanceRecord(Fault fault, int slotId);
}
