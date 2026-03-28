// lib/features/setup_wizard/data/datasource/setup_wizard_datasource.dart
//
// [SWREQ-SETUP-DATA-002]
// DataSource arayüzü — mock ve remote implementasyonlar bu kontratı uygular.
// Sınıf: Class B

import 'package:result_dart/result_dart.dart';
import '../dto/cabin_config_dto.dart';

abstract interface class SetupWizardDataSource {
  /// Kabin konfigürasyonunu sunucuya kaydeder.
  /// [SWREQ-SETUP-DATA-003]
  Future<Result<CabinConfigDto>> saveCabinConfig(CabinConfigDto dto);

  /// Cihazın fiziksel çekmece yapısını okur (standart kabin tarama).
  /// [SWREQ-SETUP-DATA-004]
  Future<Result<CabinConfigDto>> scanDeviceDrawerConfig(String ipAddress);
}
