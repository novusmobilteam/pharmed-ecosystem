// [SWREQ-CORE-003] [IEC 62304 §5.5]
// Kalıcı uygulama ayarları — ilk kurulum durumu ve cihaz modu.
// HiveCache wrapper'ından bağımsız; tüm flavor'larda yazar.
// Sınıf: Class B

import 'package:hive_flutter/hive_flutter.dart';

class AppSettingsCache {
  static const _boxName = 'app_settings';
  static const _keySetupDone = 'setup_done';
  static const _keyDeviceMode = 'device_mode';
  static const _keyCurrentCabinId = 'current_cabin_id';
  static const _keyCurrentStationId = 'current_station_id';
  static const _keyLanguage = 'language';
  static const _keyComPort = 'com_port';
  static const _keyManualRts = 'manual_rts';

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
  }

  /// Kayıtlı cihaz modunu döndürür. null → kurulum henüz yapılmamış.
  Future<String?> getDeviceMode() async {
    await _open();
    var type = _box!.get(_keyDeviceMode) as String?;
    return type;
  }

  Future<void> saveCurrentCabinId(int cabinId, {int? stationId}) async {
    await _open();
    await _box!.put(_keyCurrentCabinId, cabinId);
    await _box!.put(_keyCurrentStationId, stationId);
  }

  Future<int?> getCurrentCabinId() async {
    await _open();
    return _box!.get(_keyCurrentCabinId) as int?;
  }

  Future<int?> getCurrentStationId() async {
    await _open();
    return _box!.get(_keyCurrentStationId) as int?;
  }

  Future<void> resetSetup() async {
    await _open();
    await _box!.delete(_keySetupDone);
    await _box!.delete(_keyDeviceMode);
    await _box!.delete(_keyComPort);
    // currentCabinId varsa onu da sil
    await _box!.delete(_keyCurrentCabinId);
  }

  /// [SWREQ-UI-SETTINGS-002] Seçili dil kodunu kaydeder ('tr' | 'en' | 'ar').
  Future<void> saveLanguage(String code) async {
    await _open();
    await _box!.put(_keyLanguage, code);
  }

  /// [SWREQ-UI-SETTINGS-002] Kayıtlı dil kodunu döndürür. null → varsayılan ('tr').
  Future<String?> getLanguage() async {
    await _open();
    return _box!.get(_keyLanguage) as String?;
  }

  Future<void> saveComPort(String port) async {
    await _open();
    await _box!.put(_keyComPort, port);
  }

  Future<String?> getComPort() async {
    await _open();
    return _box!.get(_keyComPort) as String?;
  }

  Future<void> setManualRts(bool enabled) async {
    await _open();
    await _box!.put(_keyManualRts, enabled);
  }

  Future<bool> getManualRts() async {
    await _open();
    // Varsayılan: false (Waveshare otomatik-yön converter, saha standardı)
    return _box!.get(_keyManualRts, defaultValue: false) as bool;
  }
}
