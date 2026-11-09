// [SWREQ-NET-007] Log gönderiminin ağ tarafı.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../flavor/app_flavor.dart';
import '../logging/shipping/shipping.dart';
import 'network_providers.dart';

/// Log gönderimi için AYRI APIManager (kamera kayıt yüklemesiyle aynı gerekçe):
/// arka plan isteğinin 401'i kullanıcının oturumunu kapatmamalı ve gönderim
/// ekranların bağlantı havuzuyla yarışmamalı.
final logApiManagerProvider = Provider<APIManager>((ref) {
  final config = FlavorConfig.instance;
  return APIManager(
    baseUrl: config.baseUrl,
    tokenProvider: _BackgroundTokenProvider(ref.read(tokenHolderProvider)),
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
  );
});

final deviceLogRemoteDataSourceProvider = Provider<DeviceLogRemoteDataSource>(
  (ref) => DeviceLogRemoteDataSource(apiManager: ref.read(logApiManagerProvider)),
);

/// Gönderim kapalıysa (LOG_UPLOAD_ENABLED=false) null.
final logUploadWorkerProvider = Provider<LogUploadWorker?>((ref) {
  final shipping = LogShipping.instance;
  if (shipping == null) return null;
  final worker = LogUploadWorker(shipping: shipping, post: ref.read(deviceLogRemoteDataSourceProvider).postBatch);
  ref.onDispose(worker.dispose);
  return worker;
});

/// MyApp açılışında okunur.
final logShippingBootstrapProvider = Provider<void>((ref) {
  ref.read(logUploadWorkerProvider)?.start();
});

/// Token'ı ana oturumdan okur, 401'de oturumu kapatmaz.
class _BackgroundTokenProvider implements AuthTokenProvider {
  const _BackgroundTokenProvider(this._inner);
  final AuthTokenProvider _inner;

  @override
  String? get accessToken => _inner.accessToken;

  @override
  String get currentLocale => _inner.currentLocale;

  @override
  void onUnauthorized() {}
}
