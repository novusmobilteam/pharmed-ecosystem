// lib/features/setup_wizard/data/datasource/setup_wizard_mock_datasource.dart
//
// [SWREQ-SETUP-DATA-005]
// Mock datasource — gerçek ağ çağrısı yapmaz.
// Sınıf: Class B

import 'package:result_dart/result_dart.dart';
import '../dto/cabin_config_dto.dart';
import 'setup_wizard_datasource.dart';

class SetupWizardMockDataSource implements SetupWizardDataSource {
  @override
  Future<Result<CabinConfigDto>> saveCabinConfig(CabinConfigDto dto) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    // Mock: id atayarak geri dön
    return Success(
      CabinConfigDto(
        id: 304,
        cabinetType: dto.cabinetType,
        cabinName: dto.cabinName,
        location: dto.location,
        ipAddress: dto.ipAddress,
        port: dto.port,
        timeoutSeconds: dto.timeoutSeconds,
        serviceName: dto.serviceName,
        departmentId: dto.departmentId,
        rooms: dto.rooms,
        sections: dto.sections,
        drawerType: dto.drawerType,
        depth: dto.depth,
        splitConfig: dto.splitConfig,
        mobileDrawers: dto.mobileDrawers,
      ),
    );
  }

  @override
  Future<Result<CabinConfigDto>> scanDeviceDrawerConfig(String ipAddress) async {
    // 3 saniyeye yayılmış animasyonlu tarama simülasyonu
    await Future.delayed(const Duration(seconds: 3));
    return const Success(CabinConfigDto(sections: 5, drawerType: 'cubic4x4', depth: 6, splitConfig: 'Tek (5)'));
  }
}

/// Hata senaryosu testi için
class SetupWizardMockErrorDataSource implements SetupWizardDataSource {
  @override
  Future<Result<CabinConfigDto>> saveCabinConfig(CabinConfigDto dto) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return Failure(Exception('Kayıt sırasında sunucu hatası oluştu. Lütfen tekrar deneyin.'));
  }

  @override
  Future<Result<CabinConfigDto>> scanDeviceDrawerConfig(String ipAddress) async {
    await Future.delayed(const Duration(seconds: 3));
    return Failure(Exception('Cihaza bağlanılamadı. IP adresini ve ağ bağlantısını kontrol edin.'));
  }
}
