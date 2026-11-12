// [SWREQ-NET-001]
// Ağ katmanı provider'ları.
// Circular dependency önlemi: APIManager → TokenHolder → token string
// AuthNotifier login/logout sonrası TokenHolder'ı günceller.
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_client/core/providers/auth_providers.dart';
import 'package:pharmed_client/features/auth/notifier/auth_notifier.dart';
import 'package:pharmed_data/pharmed_data.dart';

// ── AuthCacheDataSource ───────────────────────────────────────────

final authCacheProvider = Provider<AuthCacheDataSource>((ref) {
  return AuthCacheDataSource(boxPrefix: 'client_');
});

// ── TokenHolder ───────────────────────────────────────────────────
//
// Basit mutable container — APIManager ve AuthNotifier arasında köprü.
// AuthNotifier login sonrası token'ı buraya yazar.
// TokenInterceptor buradan sync okur.
// Circular dependency yok: APIManager → TokenHolder (tek yön).

final Provider<TokenHolder> tokenHolderProvider = Provider<TokenHolder>((ref) {
  return TokenHolder();
});

// ── APIManager ────────────────────────────────────────────────────

final Provider<APIManager> apiManagerProvider = Provider<APIManager>((ref) {
  final config = FlavorConfig.instance;
  final tokenHolder = ref.read(tokenHolderProvider);

  // 401 callback'ini AuthNotifier'a bağla
  tokenHolder.setOnUnauthorized(() {
    ref.read(authNotifierProvider.notifier).onUnauthorized();
  });

  // [SWREQ-DATA-AUTH-005] 401 → önce refresh token ile oturumu yenile.
  // Lazy okunur: authRepository → userRepository → apiManager döngüsü
  // yalnızca çağrı anında (apiManager hazırken) çözülür.
  tokenHolder.setRefreshHandler(() async {
    final result = await ref.read(refreshSessionUseCaseProvider).call();
    return result.isSuccess;
  });

  return APIManager(
    baseUrl: config.baseUrl,
    tokenProvider: tokenHolder,
    connectTimeout: Duration(milliseconds: config.connectTimeoutMs),
    receiveTimeout: Duration(milliseconds: config.receiveTimeoutMs),
  );
});
