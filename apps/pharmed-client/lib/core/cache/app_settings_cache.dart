// [SWREQ-CORE-003] [IEC 62304 §5.5]
// Kalıcı uygulama ayarları — ilk kurulum durumu ve cihaz modu.
// HiveCache wrapper'ından bağımsız; tüm flavor'larda yazar.
// Sınıf: Class B

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_client/features/settings/domain/model/settings_state.dart';
import 'package:pharmed_client/features/settings/presentation/provider/settings_provider.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

final appSettingsCacheProvider = Provider<AppSettingsCache>((ref) {
  return appSettingsCache; // mevcut global singleton
});

final deviceModeProvider = FutureProvider.autoDispose<String?>((ref) async {
  if (kDebugMode) {
    final debugMode = ref.watch(settingsNotifierProvider).debugCabinMode;
    return switch (debugMode) {
      DebugCabinMode.master => CabinType.master.name,
      DebugCabinMode.mobile => CabinType.mobile.name,
    };
  }
  final cache = ref.read(appSettingsCacheProvider);
  return cache.getDeviceMode();
});

class AppSettingsCache {
  static const _boxName = 'app_settings';
  static const _keySetupDone = 'setup_done';
  static const _keyDeviceMode = 'device_mode';
  static const _keyCurrentCabinId = 'current_cabin_id';

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

  Future<void> saveCurrentCabinId(int cabinId) async {
    await _open();
    await _box!.put(_keyCurrentCabinId, cabinId);
  }

  Future<int?> getCurrentCabinId() async {
    await _open();
    return _box!.get(_keyCurrentCabinId) as int?;
  }

  Future<void> resetSetup() async {
    await _open();
    await _box!.delete(_keySetupDone);
    await _box!.delete(_keyDeviceMode);
    // currentCabinId varsa onu da sil
    await _box!.delete(_keyCurrentCabinId);
  }
}

/// Global singleton — notifier ve router tarafından paylaşılır.
final appSettingsCache = AppSettingsCache();
