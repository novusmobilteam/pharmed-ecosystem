// lib/core/hardware/hardware_mode.dart
//
// [SWREQ-CORE-002]
// Cihaz servislerinin (seri port, kabin kartı, tepsi kilidi, RFID, parmak izi
// okuyucu, fiş yazıcı) gerçek mi sahte mi olacağı. Flavor'dan BAĞIMSIZDIR:
// flavor hangi backend'e gidileceğini, bu ayar cihazların olup olmadığını
// belirler.
//
//   --dart-define=HARDWARE=mock   Bilgisayar test sürümü: cihazlar sahte
//   --dart-define=HARDWARE=real   Kabin sürümü: cihazlar gerçek
//
// Verilmezse flavor'a göre: prod → real, dev / mock → mock.
// Derleme zamanında belirlenir, çalışırken değişmez.
//
// Sınıf: Class B

import '../flavor/app_flavor.dart';

enum HardwareMode {
  /// Cihazlar yok; sahte servisler "varmış gibi" davranır.
  mock,

  /// Gerçek kabin donanımı.
  real,
}

abstract final class HardwareConfig {
  static const _raw = String.fromEnvironment('HARDWARE');

  static HardwareMode get mode => switch (_raw.toLowerCase()) {
    'real' => HardwareMode.real,
    'mock' => HardwareMode.mock,
    _ => FlavorConfig.instance.isProd ? HardwareMode.real : HardwareMode.mock,
  };

  static bool get isMock => mode == HardwareMode.mock;

  /// Loglarda ve ekrandaki sürüm etiketinde görünen kısa ad: `dev-pc`, `dev-kabin`, `prod`.
  static String get variant {
    final flavor = FlavorConfig.instance.flavor.name;
    if (FlavorConfig.instance.isProd && !isMock) return flavor;
    return '$flavor-${isMock ? 'pc' : 'kabin'}';
  }
}
