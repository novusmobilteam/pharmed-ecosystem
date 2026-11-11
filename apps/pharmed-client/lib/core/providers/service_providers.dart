import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_hardware/pharmed_hardware.dart';

import '../cache/app_settings_cache.dart';
import '../hardware/hardware_mode.dart';
import '../services/tray_lock/mock_tray_lock_service.dart';
import '../services/tray_lock/tray_lock_service.dart';

// Cihaz servisleri flavor'a değil HARDWARE ayarına göre seçilir (bkz. hardware_mode.dart).

final serialServiceProvider = Provider<ISerialCommunicationService>((ref) {
  return switch (HardwareConfig.mode) {
    HardwareMode.mock => MockSerialCommunicationService(),
    HardwareMode.real => SerialCommunicationService(),
  };
});

final cabinOperationServiceProvider = Provider<ICabinOperationService>((ref) {
  return switch (HardwareConfig.mode) {
    HardwareMode.mock => MockCabinOperationService(),
    HardwareMode.real => CabinOperationService(
      serialService: ref.read(serialServiceProvider),
      readSavedComPort: ref.read(appSettingsCacheProvider).getComPort,
    ),
  };
});

/// Serum kabini avadanlık kilit kartı. Master kabinle aynı seri hattı kullanır.
final trayLockServiceProvider = Provider<ITrayLockService>((ref) {
  return switch (HardwareConfig.mode) {
    HardwareMode.mock => MockTrayLockService(),
    HardwareMode.real => TrayLockService(
      serialService: ref.read(serialServiceProvider),
      cabinOperationService: ref.read(cabinOperationServiceProvider),
    ),
  };
});

final rfidServiceProvider = Provider<IRfidService>((ref) {
  return switch (HardwareConfig.mode) {
    HardwareMode.mock => MockRfidService(),
    HardwareMode.real => RfidService(),
  };
});
