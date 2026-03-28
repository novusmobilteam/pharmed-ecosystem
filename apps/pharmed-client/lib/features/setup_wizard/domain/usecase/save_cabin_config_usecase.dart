// lib/features/setup_wizard/domain/usecase/save_cabin_config_usecase.dart
//
// [SWREQ-SETUP-UC-001] [IEC 62304 §5.5]
// Kabin kurulum konfigürasyonunu kalıcı hale getirir.
// Repository'yi çağırır, başarı/hata sonucunu döner.
// Sınıf: Class B

import 'package:result_dart/result_dart.dart';
import '../model/cabin_setup_config.dart';
import '../../data/repository/setup_wizard_repository_impl.dart';

class SaveCabinConfigUseCase {
  const SaveCabinConfigUseCase({required this.repository});

  final SetupWizardRepositoryImpl repository;

  /// [SWREQ-SETUP-UC-001]
  /// Kabin konfigürasyonunu kaydeder.
  /// Başarıda yeni kabin ID'sini döner.
  Future<Result<int>> call(CabinSetupConfig config) {
    return repository.saveCabinConfig(config);
  }
}

class ScanDeviceDrawerConfigUseCase {
  const ScanDeviceDrawerConfigUseCase({required this.repository});

  final SetupWizardRepositoryImpl repository;

  /// [SWREQ-SETUP-UC-002]
  /// Cihazın fiziksel çekmece yapısını okur (standart kabin tarama adımı).
  Future<Result<StandardDrawerConfig>> call(String ipAddress) {
    return repository.scanDeviceDrawerConfig(ipAddress);
  }
}
