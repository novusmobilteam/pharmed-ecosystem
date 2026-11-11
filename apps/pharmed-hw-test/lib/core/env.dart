/// Derleme ortamı. `lib/main_<flavor>.dart` dosyaları [AppEnv.init] çağırır.
class AppEnv {
  AppEnv._(this.flavor, this.baseUrl);

  final String flavor;
  final String baseUrl;

  static late final AppEnv instance;

  static void init({required String flavor, required String baseUrl}) {
    instance = AppEnv._(flavor, baseUrl);
  }

  /// CI'da `--dart-define=APP_VERSION=...` ile verilir.
  static const version = String.fromEnvironment('APP_VERSION', defaultValue: 'local');
}
