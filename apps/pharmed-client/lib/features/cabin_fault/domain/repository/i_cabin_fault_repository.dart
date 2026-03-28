import 'package:pharmed_core/pharmed_core.dart';

import '../entity/cabin_fault.dart';

abstract class ICabinFaultRepository {
  /// Bakım/Arıza kayıtlarını getiren servis
  Future<Result<List<CabinFault>>> getCabinFaultRecords();

  /// Arıza kaydı oluşturan servis
  Future<Result<void>> createFaultRecord(CabinFault fault, int slotId);

  /// Arıza kaydı temizleyen servis
  Future<Result<void>> clearFaultRecord(CabinFault fault, int slotId);

  /// Bakım kaydı oluşturan servis
  Future<Result<void>> createMaintenanceRecord(CabinFault fault, int slotId);

  /// Bakım kaydı temizleyen servis
  Future<Result<void>> clearMaintenanceRecord(CabinFault fault, int slotId);
}
