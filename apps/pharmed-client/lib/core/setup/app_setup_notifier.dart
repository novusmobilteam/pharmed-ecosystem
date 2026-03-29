// lib/core/setup/app_setup_notifier.dart
//
// [SWREQ-CORE-003] [IEC 62304 §5.5]
// Kurulum durumu yönetimi.
// AsyncLoading → Hive okunuyor
// AsyncData(false) → ilk çalıştırma, wizard açılır
// AsyncData(true)  → kurulum tamamlı, dashboard açılır
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cache/app_settings_cache.dart';

final appSetupStatusProvider = AsyncNotifierProvider<AppSetupStatusNotifier, bool>(AppSetupStatusNotifier.new);

class AppSetupStatusNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => appSettingsCache.isSetupComplete();

  /// Wizard tamamlandığında çağrılır → AppRouter dashboard'a geçer.
  void markComplete() {
    state = const AsyncData(true);
  }
}
