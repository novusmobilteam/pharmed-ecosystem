import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../features/user/user.dart';
import 'persistence/auth_persistence.dart';

class AuthStorageNotifier extends ChangeNotifier implements AuthTokenProvider {
  final AuthPersistence _store;

  AuthStorageNotifier({required AuthPersistence store}) : _store = store;

  @override
  void onUnauthorized() => clearAuth();

  @override
  String? get accessToken => _store.accessToken;
  String? get email => _store.email;
  String? get password => _store.password;
  User? get user => _store.user;

  Future<void> saveToken(String? token) async {
    await _store.saveToken(token);
    notifyListeners();
  }

  Future<void> saveCredentials(String email, String password) async {
    await _store.saveCredentials(email, password);
  }

  Future<void> saveUser(User? user) async {
    await _store.saveUser(user);
    notifyListeners();
  }

  Future<void> clearAuth() async {
    await _store.clearAuth();
    notifyListeners();
  }
}
