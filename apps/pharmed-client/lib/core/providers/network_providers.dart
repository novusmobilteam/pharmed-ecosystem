// lib/core/providers/network_providers.dart
//
// [SWREQ-NET-001]
// Ağ katmanı provider'ları.
// Circular dependency önlemi: APIManager → TokenHolder → token string
// AuthNotifier login/logout sonrası TokenHolder'ı günceller.
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_client/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:pharmed_data/pharmed_data.dart';

// ── AuthCacheDataSource ───────────────────────────────────────────

final authCacheProvider = Provider<AuthCacheDataSource>((ref) {
  return AuthCacheDataSource();
});

// ── TokenHolder ───────────────────────────────────────────────────
//
// Basit mutable container — APIManager ve AuthNotifier arasında köprü.
// AuthNotifier login sonrası token'ı buraya yazar.
// TokenInterceptor buradan sync okur.
// Circular dependency yok: APIManager → TokenHolder (tek yön).

final tokenHolderProvider = Provider<TokenHolder>((ref) {
  return TokenHolder();
});

class TokenHolder implements AuthTokenProvider {
  String? _token;

  void setToken(String? token) => _token = token;

  @override
  String? get accessToken => _token;

  @override
  void onUnauthorized() {
    // AuthNotifier ref olmadan çağrılamaz — callback ile çözülür
    _onUnauthorized?.call();
  }

  void Function()? _onUnauthorized;

  void setOnUnauthorized(void Function() callback) {
    _onUnauthorized = callback;
  }
}

// ── APIManager ────────────────────────────────────────────────────

final apiManagerProvider = Provider<APIManager>((ref) {
  final config = FlavorConfig.instance;
  final tokenHolder = ref.read(tokenHolderProvider);

  // 401 callback'ini AuthNotifier'a bağla
  tokenHolder.setOnUnauthorized(() {
    ref.read(authNotifierProvider.notifier).onUnauthorized();
  });

  return APIManager(
    baseUrl: config.baseUrl,
    tokenProvider: tokenHolder,
    connectTimeout: Duration(milliseconds: config.connectTimeoutMs),
    receiveTimeout: Duration(milliseconds: config.receiveTimeoutMs),
  );
});
