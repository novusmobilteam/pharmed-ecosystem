// [SWREQ-UI-AUTH-001]
// Auth katmanı provider'ları.
// Sınıf: Class B

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import '../config/auth_config.dart';
import 'providers.dart';

// ── Config ────────────────────────────────────────────────────────

final authConfigProvider = Provider<AuthConfig>((ref) {
  return AuthConfig(inactivityTimeoutMinutes: 10, warningSeconds: 60);
});

// ── Plain Dio — login endpoint'i token gerektirmez ────────────────

final plainDioProvider = Provider<Dio>((ref) {
  final config = FlavorConfig.instance;
  return Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: Duration(milliseconds: config.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: config.receiveTimeoutMs),
      headers: {'Content-Type': 'application/json'},
    ),
  );
});

// ── Auth datasource'ları ──────────────────────────────────────────

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(dio: ref.read(plainDioProvider));
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    cacheDataSource: ref.read(authCacheProvider),
    userReader: ref.read(userRepositoryProvider),
    tokenHolder: ref.read(tokenHolderProvider),
  );
});

final userMapperProvider = Provider<UserMapper>((ref) {
  return const UserMapper();
});

// ── Use case'ler ──────────────────────────────────────────────────

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final loginWithBadgeUseCaseProvider = Provider<LoginWithBadgeUseCase>((ref) {
  return LoginWithBadgeUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});
