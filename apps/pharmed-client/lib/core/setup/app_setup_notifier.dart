// [SWREQ-CORE-003] [IEC 62304 §5.5]
// Kurulum durumu yönetimi.
// null   → Hive okunuyor (yükleniyor)
// false  → ilk çalıştırma, wizard açılır
// true   → kurulum tamamlı, dashboard açılır
// Sınıf: Class B

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../cache/app_settings_cache.dart';

class AppSetupStatusNotifier extends ChangeNotifier {
  AppSetupStatusNotifier({required AppSettingsCache appSettingsCache}) : _appSettingsCache = appSettingsCache {
    unawaited(_load());
  }

  final AppSettingsCache _appSettingsCache;

  bool _isDisposed = false;

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// null → henüz yüklenmedi (loading). Yüklendikten sonra true/false.
  bool? _isSetupComplete;
  bool? get isSetupComplete => _isSetupComplete;

  bool get isLoading => _isSetupComplete == null;

  /// Hive okuma sırasında bir hata oluşursa burada tutulur — AppRouter
  /// bunu AsyncError() karşılığı olarak kullanabilir.
  Object? _error;
  Object? get error => _error;

  Future<void> _load() async {
    try {
      final result = await _appSettingsCache.isSetupComplete();
      if (_isDisposed) return;
      _isSetupComplete = result;
      _error = null;
      _notify();
    } catch (e) {
      if (_isDisposed) return;
      _error = e;
      _notify();
    }
  }

  /// Wizard tamamlandığında çağrılır → AppRouter dashboard'a geçer.
  void markComplete() {
    _isSetupComplete = true;
    _error = null;
    _notify();
  }

  void markIncomplete() {
    _isSetupComplete = false;
    _error = null;
    _notify();
  }
}
