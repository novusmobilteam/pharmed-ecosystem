// packages/pharmed_data/lib/src/auth/repository/auth_repository_impl.dart
//
// [SWREQ-DATA-AUTH-003]
// Login akışı:
//   1. AuthRemoteDataSource.login()    → access + refresh token
//   2. cache.saveToken / saveRefreshToken
//   3. UserDataSource.getCurrentUser() → UserDTO
//      (token artık Hive'da, interceptor onu okur)
//   4. AppUser'a map et
//   5. cache.saveUser(appUser)
//   6. AuthToken döndür
//
// Oturum yenileme [SWREQ-DATA-AUTH-005]:
//   refreshSession() → cache'teki refresh token ile /Login/refresh,
//   yeni token çifti cache'e + TokenHolder'a yazılır.
//
// UserDataSource bağımlılığı constructor'dan inject edilir.
// Bu çapraz-bağımlılık değil — auth akışının zorunlu ikinci adımı.
// Sınıf: Class B

import 'package:dio/dio.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl({
    required IAuthRemoteDataSource remoteDataSource,
    required IAuthCacheDataSource cacheDataSource,
    required IUserReader userReader,
    required TokenHolder tokenHolder,
  }) : _remote = remoteDataSource,
       _cache = cacheDataSource,
       _user = userReader,
       _tokenHolder = tokenHolder;

  final IAuthRemoteDataSource _remote;
  final IAuthCacheDataSource _cache;
  final IUserReader _user;
  final TokenHolder _tokenHolder;

  @override
  Future<Result<AuthToken>> login({
    required String email,
    required String password,
    String? macAddress,
    int? stationId,
  }) async {
    try {
      // 1. Token al
      final tokens = await _remote.login(
        email: email,
        password: password,
        macAddress: macAddress,
        stationId: stationId,
      );
      final token = tokens.accessToken;

      // 2. Token'ı cache'e yaz — interceptor bir sonraki istekte bunu okur
      await _saveTokens(tokens);

      // 3. Kullanıcı bilgisini çek
      final userResult = await _user.getCurrentUser();

      if (userResult.isError) {
        // Token kaydedildi ama user alınamadı — cache'i temizle, tutarsız state bırakma
        await _cache.clear();
        return Result.error(ServiceException(message: contextlessL10n().authError_userInfoFetchFailed, statusCode: 0));
      }

      final userDto = userResult.data;

      if (userDto == null) {
        await _cache.clear();
        return Result.error(ServiceException(message: contextlessL10n().authError_userInfoEmpty, statusCode: 404));
      }

      print(userDto.toString());
      // 4. Slim AppUser'a dönüştür
      final appUser = AppUser(
        id: userDto.id ?? 0,
        email: userDto.email ?? email,
        name: userDto.name ?? '',
        surname: userDto.surname ?? '',
        fullName: [userDto.name, userDto.surname].whereType<String>().join(' ').trim(),
        roleName: userDto.role?.name ?? '',
        isAdmin: userDto.isAdmin ?? false,
        isNotOrdered: userDto.isNotOrdered,
        roleId: userDto.role?.id ?? 0,
        canCreateEmergencyPatient: userDto.canCreateEmergencyPatient,
        canCollectOverdueMedication: userDto.canCollectOverdueMedication,
        stationIds: userDto.stationIds ?? const [],
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
  Future<Result<AuthToken>> loginWithBadge({required String cardData, String? macAddress}) async {
    try {
      // 1. Token al
      final tokens = await _remote.loginWithBadge(cardData: cardData, macAddress: macAddress);
      final token = tokens.accessToken;

      // 2. Token'ı cache'e yaz — interceptor bir sonraki istekte bunu okur
      await _saveTokens(tokens);

      // 3. Kullanıcı bilgisini çek
      final userResult = await _user.getCurrentUser();

      if (userResult.isError) {
        // Token kaydedildi ama user alınamadı — cache'i temizle, tutarsız state bırakma
        await _cache.clear();
        return Result.error(ServiceException(message: contextlessL10n().authError_userInfoFetchFailed, statusCode: 0));
      }

      final userDto = userResult.data;

      if (userDto == null) {
        await _cache.clear();
        return Result.error(ServiceException(message: contextlessL10n().authError_userInfoEmpty, statusCode: 404));
      }

      // 4. Slim AppUser'a dönüştür
      final appUser = AppUser(
        id: userDto.id ?? 0,
        email: userDto.email ?? '',
        name: userDto.name ?? '',
        surname: userDto.surname ?? '',
        fullName: [userDto.name, userDto.surname].whereType<String>().join(' ').trim(),
        roleName: userDto.role?.name ?? '',
        isAdmin: userDto.isAdmin ?? false,
        isNotOrdered: userDto.isNotOrdered,
        roleId: userDto.role?.id ?? 0,
        stationIds: userDto.stationIds ?? const [],
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
  Future<Result<AuthToken>> loginWithFingerprint(FingerprintLoginRequest request) async {
    print(request.toString());
    try {
      final tokens = await _remote.loginWithFingerprint(const FingerprintMapper().toLoginDto(request));
      return await _completeLogin(tokens);
    } on DioException catch (e) {
      return Result.error(ServiceException(message: _parseDioError(e), statusCode: e.response?.statusCode ?? 0));
    } catch (e) {
      return Result.error(ServiceException(message: e.toString(), statusCode: 0));
    }
  }

  /// Token alındıktan sonraki ortak adımlar (bkz. dosya başındaki akış 2–6).
  Future<Result<AuthToken>> _completeLogin(AuthSessionTokens tokens) async {
    final token = tokens.accessToken;
    await _saveTokens(tokens);

    final userResult = await _user.getCurrentUser();
    if (userResult.isError) {
      await _cache.clear();
      return Result.error(ServiceException(message: contextlessL10n().authError_userInfoFetchFailed, statusCode: 0));
    }
    final userDto = userResult.data;
    if (userDto == null) {
      await _cache.clear();
      return Result.error(ServiceException(message: contextlessL10n().authError_userInfoEmpty, statusCode: 404));
    }

    final appUser = AppUser(
      id: userDto.id ?? 0,
      email: userDto.email ?? '',
      name: userDto.name ?? '',
      surname: userDto.surname ?? '',
      fullName: [userDto.name, userDto.surname].whereType<String>().join(' ').trim(),
      roleName: userDto.role?.name ?? '',
      isAdmin: userDto.isAdmin ?? false,
      isNotOrdered: userDto.isNotOrdered,
      roleId: userDto.role?.id ?? 0,
      canCreateEmergencyPatient: userDto.canCreateEmergencyPatient,
      canCollectOverdueMedication: userDto.canCollectOverdueMedication,
      stationIds: userDto.stationIds ?? const [],
    );
    await _cache.saveUser(appUser);
    return Result.ok(AuthToken(accessToken: token, user: appUser));
  }

  /// Access + refresh token'ı cache'e ve TokenHolder'a yazar.
  /// Login yanıtında refresh token yoksa eskisi silinir (başka kullanıcıya ait olabilir).
  Future<void> _saveTokens(AuthSessionTokens tokens) async {
    await _cache.saveToken(tokens.accessToken);
    await _cache.saveRefreshToken(tokens.refreshToken);
    _tokenHolder.setToken(tokens.accessToken);
  }

  @override
  Future<Result<String>> refreshSession() async {
    try {
      final refreshToken = await _cache.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        MedLogger.warn(unit: _unit, swreq: _swreqRefresh, message: 'Oturum yenilenemedi: saklı refresh token yok');
        return const Result.error(ServiceException(message: 'No refresh token stored', statusCode: 401));
      }

      final tokens = await _remote.refreshSession(refreshToken: refreshToken);

      // İstek sürerken logout olduysa (cache temizlendi / başka kullanıcı girdi)
      // yeni token'ı YAZMA — kapanmış oturumu geri diriltme.
      final current = await _cache.readRefreshToken();
      if (current != refreshToken) {
        MedLogger.warn(
          unit: _unit,
          swreq: _swreqRefresh,
          message: 'Oturum yenileme sonucu atıldı: oturum bu sırada değişti',
        );
        return const Result.error(ServiceException(message: 'Session changed during refresh', statusCode: 401));
      }

      await _cache.saveToken(tokens.accessToken);
      // Sunucu yeni refresh token dönmezse mevcut olan geçerli kalır.
      if (tokens.refreshToken != null) await _cache.saveRefreshToken(tokens.refreshToken);
      _tokenHolder.setToken(tokens.accessToken);

      MedLogger.info(unit: _unit, swreq: _swreqRefresh, message: 'Oturum yenilendi (access token)');
      return Result.ok(tokens.accessToken);
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      MedLogger.warn(
        unit: _unit,
        swreq: _swreqRefresh,
        message: 'Oturum yenileme isteği başarısız',
        context: {'statusCode': status, 'error': _parseDioError(e)},
      );
      return Result.error(ServiceException(message: _parseDioError(e), statusCode: status));
    } catch (e, st) {
      MedLogger.error(unit: _unit, swreq: _swreqRefresh, message: 'Oturum yenileme hatası', error: e, stackTrace: st);
      return Result.error(ServiceException(message: e.toString(), statusCode: 0));
    }
  }

  static const _unit = 'SW-UNIT-DATA';
  static const _swreqRefresh = 'SWREQ-DATA-AUTH-005';

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
        return error ?? message ?? contextlessL10n().authError_genericLoginError;
      }
    } catch (_) {}
    return e.message ?? contextlessL10n().authError_genericLoginError;
  }
}
