import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IFaultRepository {
  /// Master kabin arıza/bakım kayıtlarını getiren servis
  Future<Result<List<MasterFault>>> getMasterCabinFaultRecords();

  /// Mobil kabin arıza/bakım kayıtlarını getiren servis
  Future<Result<List<MobileFault>>> getMobileCabinFaultRecords();

  /// Master kabin arıza kaydı oluşturan servis
  Future<Result<void>> createMasterCabinFaultRecord(MasterFault fault, int cellId);

  /// Mobil kabin arıza kaydı oluşturan servis
  Future<Result<void>> createMobilCabinFaultRecord(MobileFault fault, int slotId);

  /// Master kabin arıza kaydını temizleyen servis
  Future<Result<void>> clearMasterCabinFaultRecord(MasterFault fault, int cellId);

  /// Mobil kabin arıza kaydını temizleyen servis
  Future<Result<void>> clearMobilCabinFaultRecord(MobileFault fault, int slotId);

  /// Master kabin bakım kaydı oluşturan servis
  Future<Result<void>> createMasterCabinMaintenanceRecord(MasterFault fault, int cellId);

  /// Mobil kabin bakım kaydı oluşturan servis
  Future<Result<void>> createMobilCabinMaintenanceRecord(MobileFault fault, int slotId);

  /// Master kabin bakım kaydını temizleyen servis
  Future<Result<void>> clearMasterCabinMaintenanceRecord(MasterFault fault, int cellId);

  /// Mobil kabin bakım kaydını temizleyen servis
  Future<Result<void>> clearMobilCabinMaintenanceRecord(MobileFault fault, int slotId);
}
