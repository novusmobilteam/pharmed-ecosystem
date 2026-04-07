// lib/core/flavor/app_flavor.dart
//
// [SWREQ-CORE-001]
// Uygulama flavor sistemi.
// Flavor bilgisi compile-time'da belirlenir, runtime'da değiştirilemez.
// Bu sayede mock/dev/prod davranışı deterministik ve test edilebilirdir.
//
// Kullanım (main_mock.dart):
//   FlavorConfig.initialize(AppFlavor.mock);
//   runApp(const App());
//
// Kullanım (main_prod.dart):
//   FlavorConfig.initialize(AppFlavor.prod);
//   runApp(const App());

enum AppFlavor {
  /// Tamamen sahte veri. Servise hiç çıkılmaz.
  /// UI geliştirme ve demo için kullanılır.
  mock,

  /// Gerçek servis. Test/geliştirme ortamı URL'leri.
  /// Cache aktif.
  dev,

  /// Gerçek servis. Production URL'leri.
  /// Cache aktif.
  prod,
}

// ─────────────────────────────────────────────────────────────────
// FlavorConfig — singleton, uygulama başında bir kez initialize edilir
// ─────────────────────────────────────────────────────────────────

class FlavorConfig {
  FlavorConfig._({
    required this.flavor,
    required this.baseUrl,
    required this.connectTimeoutMs,
    required this.receiveTimeoutMs,
    required this.cacheEnabled,
    required this.cacheMaxAgeMinutes,
    required this.logNetworkCalls,
  });

  final AppFlavor flavor;
  final String baseUrl;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;
  final bool cacheEnabled;

  /// Repository stale data kararında kullanır
  final int cacheMaxAgeMinutes;
  final bool logNetworkCalls;

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    assert(_instance != null, 'FlavorConfig.initialize() çağrılmadan instance erişildi.');
    return _instance!;
  }

  static void initialize(AppFlavor flavor) {
    _instance = switch (flavor) {
      AppFlavor.mock => FlavorConfig._(
        flavor: AppFlavor.mock,
        baseUrl: 'http://mock.local', // kullanılmaz
        connectTimeoutMs: 0,
        receiveTimeoutMs: 0,
        cacheEnabled: false, // mock'ta cache gereksiz
        cacheMaxAgeMinutes: 0,
        logNetworkCalls: true,
      ),
      AppFlavor.dev => FlavorConfig._(
        flavor: AppFlavor.dev,
        baseUrl: 'https://agena.novusyazilim.com/api',
        connectTimeoutMs: 10000,
        receiveTimeoutMs: 15000,
        cacheEnabled: true,
        cacheMaxAgeMinutes: 30,
        logNetworkCalls: true, // dev'de log açık
      ),
      AppFlavor.prod => FlavorConfig._(
        flavor: AppFlavor.prod,
        baseUrl: 'https://agena.novusyazilim.com/api',
        connectTimeoutMs: 8000,
        receiveTimeoutMs: 12000,
        cacheEnabled: true,
        cacheMaxAgeMinutes: 60,
        logNetworkCalls: false,
      ),
    };
  }

  bool get isMock => flavor == AppFlavor.mock;
  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;

  @override
  String toString() => 'FlavorConfig(${flavor.name}, $baseUrl)';
}
