// [SWREQ-DATA-AUTH-002]
// Token ve AppUser bilgisini Hive'da saklar.
// İki ayrı box — token box String, user box Map.
// Hive TypeAdapter yazmak yerine Map<String,dynamic> olarak serileştiriyoruz:
// auth verisi basit ve versiyon yönetimi gerekmez.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IAuthCacheDataSource {
  Future<void> saveToken(String token);
  Future<String?> readToken();
  Future<void> saveUser(AppUser user);
  Future<AppUser?> readUser();
  Future<void> clear();
}

class AuthCacheDataSource implements IAuthCacheDataSource {
  static const _tokenBoxName = 'auth_token';
  static const _userBoxName = 'auth_user';
  static const _tokenKey = 'access_token';
  static const _userKey = 'current_user';

  @override
  Future<void> saveToken(String token) async {
    final box = await Hive.openBox<String>(_tokenBoxName);
    await box.put(_tokenKey, token);
  }

  @override
  Future<String?> readToken() async {
    final box = await Hive.openBox<String>(_tokenBoxName);
    return box.get(_tokenKey);
  }

  @override
  Future<void> saveUser(AppUser user) async {
    final box = await Hive.openBox<dynamic>(_userBoxName);
    await box.put(_userKey, {
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'surname': user.surname,
      'fullName': user.fullName,
      'role': user.role,
      'isNotOrdered': user.isNotOrdered,
      'isAdmin': user.isAdmin,
    });
  }

  @override
  Future<AppUser?> readUser() async {
    final box = await Hive.openBox<dynamic>(_userBoxName);
    final raw = box.get(_userKey);
    if (raw == null) return null;

    final map = Map<String, dynamic>.from(raw as Map);
    return AppUser(
      id: map['id'] as int? ?? 0,
      email: map['email'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      name: map['name'] as String? ?? '',
      surname: map['surname'] as String? ?? '',
      role: map['role'] as String? ?? '',
      isNotOrdered: map['isNotOrdered'] as bool? ?? false,
      isAdmin: map['isAdmin'] as bool? ?? false,
    );
  }

  @override
  Future<void> clear() async {
    final tokenBox = await Hive.openBox<String>(_tokenBoxName);
    final userBox = await Hive.openBox<dynamic>(_userBoxName);
    await Future.wait([tokenBox.clear(), userBox.clear()]);
  }
}
