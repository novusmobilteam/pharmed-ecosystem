import 'package:device_info_plus/device_info_plus.dart';

/// Cihaz kimliği. Backend istasyonu bu değerle eşleştirir (login, istasyon,
/// kabin kurulumu, dashboard).
///
/// Değer gerçek bir MAC değil; Windows'ta `systemGUID`, diğerlerinde
/// `deviceId` okunur. Örn. "B4CD266B-D2B0-4263-ADFA-A0E0F923B123".
class DeviceInfo {
  static String? _identityOverride;

  /// [SWREQ-CORE-005] Test cihazı kimliği.
  ///
  /// Bu paket kimin, hangi sürümde override verebileceğine KARAR VERMEZ —
  /// karar uygulamadadır (pharmed-client'ta yalnızca sahte donanımlı test
  /// sürümü, bkz. `DevDeviceIdentity`). null → fiziksel kimlik.
  static void setIdentityOverride(String? value) {
    _identityOverride = (value == null || value.isEmpty) ? null : value;
  }

  static bool get hasIdentityOverride => _identityOverride != null;

  static Future<String> getMacAddress() async {
    final override = _identityOverride;
    if (override != null) return override;

    final plugin = DeviceInfoPlugin();
    final deviceInfo = await plugin.deviceInfo;
    final macAddressRaw = deviceInfo.data['systemGUID'] ?? deviceInfo.data['deviceId'];
    return macAddressRaw.toString().replaceAll(RegExp(r'^\{|\}$'), '');
  }
}
