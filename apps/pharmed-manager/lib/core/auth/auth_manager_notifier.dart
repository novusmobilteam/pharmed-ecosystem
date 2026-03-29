// apps/pharmed_manager/lib/core/auth/auth_manager_notifier.dart
//
// [SWREQ-UI-AUTH-001]
// Manager tarafı auth state yönetimi.
// ChangeNotifier tabanlı — Provider ile kullanılır.
// AuthCacheDataSource üzerinden token/user okur/yazar.
// Login/logout AuthRepositoryImpl üzerinden yapılır.
// Sınıf: Class B

import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class AuthManagerNotifier extends ChangeNotifier implements AuthTokenProvider {
  AuthManagerNotifier({required AuthRepositoryImpl repository, required AuthCacheDataSource cache})
    : _repository = repository,
      _cache = cache;

  final AuthRepositoryImpl _repository;
  final AuthCacheDataSource _cache;

  AppUser? _user;
  String? _accessToken;
  String? _loginError;
  bool _isLoading = false;

  // ── Getter'lar ────────────────────────────────────────────────

  @override
  String? get accessToken => _accessToken;

  AppUser? get user => _user;
  String? get loginError => _loginError;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _accessToken != null;

  OrderStatus get orderStatus => (_user?.isNotOrdered ?? false) ? OrderStatus.orderless : OrderStatus.ordered;

  // ── Init — uygulama açılışında cache'den yükle ────────────────

  Future<void> init() async {
    _accessToken = await _cache.readToken();
    _user = await _cache.readUser();
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────────

  Future<void> login({required String email, required String password, String? macAddress}) async {
    _isLoading = true;
    _loginError = null;
    notifyListeners();

    final result = await _repository.login(email: email, password: password, macAddress: macAddress);

    result.when(
      ok: (authToken) {
        _accessToken = authToken.accessToken;
        _user = authToken.user;
        _loginError = null;
      },
      error: (failure) {
        _loginError = failure is ServiceException ? failure.message : 'Bir hata oluştu';
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // ── Logout ────────────────────────────────────────────────────

  Future<void> logout() async {
    await _repository.logout();
    _accessToken = null;
    _user = null;
    _loginError = null;
    notifyListeners();
  }

  // ── AuthTokenProvider — APIManager interceptor'ı için ─────────

  @override
  void onUnauthorized() {
    logout();
  }
}
