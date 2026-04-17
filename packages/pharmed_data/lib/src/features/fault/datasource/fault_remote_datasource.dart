import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-FAULT-001]
// Master kabin için arıza/bakım kayıtları çekmecede yer alan en küçük göz(cell) için oluşturulur.
// Mobil kabinde ise çekmecede yer alan gözler bağımsız çalışmadıkları için arıza/bakım kaydı
// çekmece(slot) için oluşturulur.
// Sınıf: Class B
class FaultRemoteDataSource extends BaseRemoteDataSource {
  FaultRemoteDataSource({required super.apiManager});

  // Master kabin path
  static const String _masterBase = '/DrawrMaintenanceMalfunction';

  // Mobil kabin path
  static const String _mobileBase = '/MobileDrawrMaintenanceMalfunction';

  @override
  String get logSwreq => 'SWREQ-DATA-FAULT-001';

  @override
  String get logUnit => 'SW-UNIT-FAULT';

  // Master kabin arıza/bakım kayıtlarını getiren servis
  Future<Result<List<MasterFaultDto>?>> getMasterCabinFaultRecords() async {
    return await fetchRequest<List<MasterFaultDto>>(
      path: _masterBase,
      parser: BaseRemoteDataSource.listParser(MasterFaultDto.fromJson),
      successLog: 'Master kabin arıza/bakım kayıtları getirildi',
      emptyLog: 'Master kabin arıza/bakım kaydı bulunamadı',
    );
  }

  // Mobil kabin arıza/bakım kayıtlarını getiren servis
  Future<Result<List<MobileFaultDto>?>> getMobileCabinFaultRecords() async {
    return await fetchRequest<List<MobileFaultDto>>(
      path: _mobileBase,
      parser: BaseRemoteDataSource.listParser(MobileFaultDto.fromJson),
      successLog: 'Mobil kabin arıza/bakım kayıtları getirildi',
      emptyLog: 'Mobil kabin arıza/bakım kaydı bulunamadı',
    );
  }

  // Master kabin arıza kaydı oluşturan servis
  Future<Result<void>> createMasterCabinFaultRecord(MasterFaultDto dto, int cellId) async {
    return await updateRequest(path: '$_masterBase/faulty/$cellId', parser: BaseRemoteDataSource.voidParser());
  }

  // Mobil kabin arıza kaydı oluşturan servis
  Future<Result<void>> createMobilCabinFaultRecord(MobileFaultDto dto, int slotId) async {
    return await updateRequest(path: '$_mobileBase/faulty/$slotId', parser: BaseRemoteDataSource.voidParser());
  }

  // Master kabin arıza kaydını temizleyen servis
  Future<Result<void>> clearMasterCabinFaultRecord(MasterFaultDto dto, int cellId) async {
    return await updateRequest(path: '$_masterBase/notFaulty/$cellId', parser: BaseRemoteDataSource.voidParser());
  }

  // Mobil kabin arıza kaydını temizleyen servis
  Future<Result<void>> clearMobilCabinFaultRecord(MobileFaultDto dto, int slotId) async {
    return await updateRequest(path: '$_mobileBase/notFaulty/$slotId', parser: BaseRemoteDataSource.voidParser());
  }

  // Master kabin bakım kaydı oluşturan servis
  Future<Result<void>> createMasterCabinMaintenanceRecord(MasterFaultDto dto, int cellId) async {
    return await updateRequest(path: '$_masterBase/maintenance/$cellId', parser: BaseRemoteDataSource.voidParser());
  }

  // Mobil kabin bakım kaydı oluşturan servis
  Future<Result<void>> createMobilCabinMaintenanceRecord(MobileFaultDto dto, int slotId) async {
    return await updateRequest(path: '$_mobileBase/maintenance/$slotId', parser: BaseRemoteDataSource.voidParser());
  }

  // Master kabin bakım kaydını temizleyen servis
  Future<Result<void>> clearMasterCabinMaintenanceRecord(MasterFaultDto dto, int cellId) async {
    return await updateRequest(path: '$_masterBase/notMaintenance/$cellId', parser: BaseRemoteDataSource.voidParser());
  }

  // Mobil kabin bakım kaydını temizleyen servis
  Future<Result<void>> clearMobilCabinMaintenanceRecord(MobileFaultDto dto, int slotId) async {
    return await updateRequest(path: '$_mobileBase/notMaintenance/$slotId', parser: BaseRemoteDataSource.voidParser());
  }
}
