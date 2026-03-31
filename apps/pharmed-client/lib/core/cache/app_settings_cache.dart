// [SWREQ-CORE-003] [IEC 62304 §5.5]
// Kalıcı uygulama ayarları — ilk kurulum durumu ve cihaz modu.
// HiveCache wrapper'ından bağımsız; tüm flavor'larda yazar.
// Sınıf: Class B

import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────

class AppSettingsCache {
  static const _boxName = 'app_settings';
  static const _keySetupDone = 'setup_done';
  static const _keyDeviceMode = 'device_mode';

  Box? _box;

  Future<void> _open() async {
    if (!(_box?.isOpen ?? false)) {
      _box = await Hive.openBox(_boxName);
    }
  }

  /// [SWREQ-CORE-003] İlk kurulum tamamlandı mı?
  Future<bool> isSetupComplete() async {
    await _open();
    return _box!.get(_keySetupDone, defaultValue: false) as bool;
  }

  /// [SWREQ-CORE-003] Kurulumu tamamlandı olarak işaretle.
  /// [deviceMode]: CabinetType.name — 'standard' veya 'mobile'
  Future<void> markSetupComplete({required String deviceMode}) async {
    await _open();
    await _box!.put(_keySetupDone, true);
    await _box!.put(_keyDeviceMode, deviceMode);

    MedLogger.info(
      unit: 'APP-SETTINGS',
      swreq: 'SWREQ-CORE-003',
      message: 'Kurulum tamamlandı olarak işaretlendi',
      context: {'deviceMode': deviceMode},
    );
  }

  /// Kayıtlı cihaz modunu döndürür. null → kurulum henüz yapılmamış.
  Future<String?> getDeviceMode() async {
    await _open();
    return _box!.get(_keyDeviceMode) as String?;
  }
}

/// Global singleton — notifier ve router tarafından paylaşılır.
final appSettingsCache = AppSettingsCache();
