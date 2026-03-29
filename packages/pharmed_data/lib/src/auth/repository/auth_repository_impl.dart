// packages/pharmed_data/lib/src/auth/repository/auth_repository_impl.dart
//
// [SWREQ-DATA-AUTH-003]
// Login akışı:
//   1. AuthRemoteDataSource.login()    → raw token
//   2. cache.saveToken(token)
//   3. UserDataSource.getCurrentUser() → UserDTO
//      (token artık Hive'da, interceptor onu okur)
//   4. AppUser'a map et
//   5. cache.saveUser(appUser)
//   6. AuthToken döndür
//
// UserDataSource bağımlılığı constructor'dan inject edilir.
// Bu çapraz-bağımlılık değil — auth akışının zorunlu ikinci adımı.
// Sınıf: Class B

import 'package:dio/dio.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../datasource/auth_cache_datasource.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl({
    required IAuthRemoteDataSource remoteDataSource,
    required IAuthCacheDataSource cacheDataSource,
    required IUserReader userReader,
  }) : _remote = remoteDataSource,
       _cache = cacheDataSource,
       _user = userReader;

  final IAuthRemoteDataSource _remote;
  final IAuthCacheDataSource _cache;
  final IUserReader _user;

  @override
  Future<Result<AuthToken>> login({required String email, required String password, String? macAddress}) async {
    try {
      // 1. Token al
      final token = await _remote.login(email: email, password: password, macAddress: macAddress);

      // 2. Token'ı cache'e yaz — interceptor bir sonraki istekte bunu okur
      await _cache.saveToken(token);

      // 3. Kullanıcı bilgisini çek
      final userResult = await _user.getCurrentUser();

      if (userResult.isError) {
        // Token kaydedildi ama user alınamadı — cache'i temizle, tutarsız state bırakma
        await _cache.clear();
        return Result.error(ServiceException(message: 'Kullanıcı bilgisi alınamadı', statusCode: 0));
      }

      final userDto = userResult.data;

      if (userDto == null) {
        await _cache.clear();
        return Result.error(ServiceException(message: 'Kullanıcı bilgisi boş döndü', statusCode: 404));
      }

      // 4. Slim AppUser'a dönüştür
      final appUser = AppUser(
        id: userDto.id ?? 0,
        email: userDto.email ?? email,
        fullName: [userDto.name, userDto.surname].whereType<String>().join(' ').trim(),
        role: userDto.role?.name ?? '',
        isAdmin: userDto.isAdmin ?? false,
        isNotOrdered: userDto.isNotOrdered,
      );

      // 5. User'ı cache'e yaz
      await _cache.saveUser(appUser);

      return Result.ok(AuthToken(accessToken: token, user: appUser));
    } on DioException catch (e) {
      return Result.error(ServiceException(message: _parseDioError(e), statusCode: e.response?.statusCode ?? 0));
    } catch (e) {
      return Result.error(ServiceException(message: e.toString(), statusCode: 0));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _cache.clear();
      return const Result.ok(null);
    } catch (e) {
      return Result.error(ServiceException(message: e.toString(), statusCode: 0));
    }
  }

  @override
  Future<String?> getStoredToken() => _cache.readToken();

  // ── Hata parse ────────────────────────────────────────────────

  String _parseDioError(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        // ApiError yapısı: { "error": "...", "message": "..." }
        final error = data['error'] as String?;
        final message = data['message'] as String?;
        return error ?? message ?? 'Bir hata oluştu';
      }
    } catch (_) {}
    return e.message ?? 'Bir hata oluştu';
  }
}
