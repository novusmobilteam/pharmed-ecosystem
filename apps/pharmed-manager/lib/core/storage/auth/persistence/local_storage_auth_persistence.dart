import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../features/user/user.dart';
import '../../../core.dart';
import 'auth_persistence.dart';

class LocalStorageAuthPersistence implements AuthPersistence {
  final SharedPreferences _prefs;

  LocalStorageAuthPersistence(this._prefs);

  static const _keyToken = 'access_token';
  static const _keyEmail = 'email';
  static const _keyPassword = 'password';
  static const _keyUser = 'current_user';

  @override
  String? get accessToken => _prefs.getString(_keyToken);

  // Ordersız işlem yapma durumu
  // isNotOrdered = true => Ordersız
  // isNotOrdered = false => Orderlı
  @override
  OrderStatus get orderStatus => (user?.isNotOrdered ?? false) ? OrderStatus.orderless : OrderStatus.ordered;

  @override
  Future<void> saveToken(String? token) async {
    if (token == null) {
      await _prefs.remove(_keyToken);
    } else {
      await _prefs.setString(_keyToken, token);
    }
  }

  @override
  String? get email => _prefs.getString(_keyEmail);

  @override
  String? get password => _prefs.getString(_keyPassword);

  @override
  Future<void> saveCredentials(String email, String password) async {
    await _prefs.setString(_keyEmail, email);
    await _prefs.setString(_keyPassword, password);
  }

  @override
  User? get user {
    final userJson = _prefs.getString(_keyUser);
    if (userJson == null) return null;

    try {
      final Map<String, dynamic> map = jsonDecode(userJson);
      return User(
        id: map['id'],
        name: map['name'],
        surname: map['surname'],
        isAdmin: map['isAdmin'],
        isNotOrdered: map['isNotOrdered'],
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveUser(User? user) async {
    if (user == null) {
      await _prefs.remove(_keyUser);
    } else {
      final minimalUser = {
        'id': user.id,
        'name': user.name,
        'surname': user.surname,
        'isAdmin': user.isAdmin,
        'isNotOrdered': user.isNotOrdered,
      };
      await _prefs.setString(_keyUser, jsonEncode(minimalUser));
    }
  }

  @override
  Future<void> clearAuth() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyPassword);
    await _prefs.remove(_keyUser);
  }
}
