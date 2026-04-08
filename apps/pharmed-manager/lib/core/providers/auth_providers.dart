// [SWREQ-UI-AUTH-001]
// Auth katmanı provider'ları.
// Sınıf: Class B

import 'package:dio/dio.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../features/auth/presentation/notifier/auth_notifier.dart';
import '../config/auth_config.dart';

class AuthProviders {
  static List<SingleChildWidget> providers() => [
    Provider<AuthConfig>(create: (_) => const AuthConfig(inactivityTimeoutMinutes: 10, warningSeconds: 60)),

    Provider<Dio>(
      create: (_) {
        final config = FlavorConfig.instance;
        return Dio(
          BaseOptions(
            baseUrl: config.baseUrl,
            connectTimeout: Duration(milliseconds: config.connectTimeoutMs),
            receiveTimeout: Duration(milliseconds: config.receiveTimeoutMs),
            headers: {'Content-Type': 'application/json'},
          ),
        );
      },
    ),

    Provider<AuthCacheDataSource>(create: (_) => AuthCacheDataSource(boxPrefix: 'manager_')),
    Provider<AuthRemoteDataSource>(create: (ctx) => AuthRemoteDataSource(dio: ctx.read<Dio>())),

    Provider<UserRemoteDataSource>(create: (ctx) => UserRemoteDataSource(apiManager: ctx.read<APIManager>())),

    Provider<UserMapper>(create: (_) => const UserMapper()),

    Provider<IUserReader>(
      create: (ctx) => UserRepositoryImpl(dataSource: ctx.read<UserRemoteDataSource>(), mapper: ctx.read<UserMapper>()),
    ),

    Provider<IAuthRepository>(
      create: (ctx) => AuthRepositoryImpl(
        remoteDataSource: ctx.read<AuthRemoteDataSource>(),
        cacheDataSource: ctx.read<AuthCacheDataSource>(),
        userReader: ctx.read<IUserReader>(),
        tokenHolder: ctx.read<TokenHolder>(),
      ),
    ),

    Provider<LoginUseCase>(create: (ctx) => LoginUseCase(ctx.read<IAuthRepository>())),

    Provider<LogoutUseCase>(create: (ctx) => LogoutUseCase(ctx.read<IAuthRepository>())),

    ChangeNotifierProvider<AuthNotifier>(
      create: (ctx) => AuthNotifier(
        loginUseCase: ctx.read<LoginUseCase>(),
        logoutUseCase: ctx.read<LogoutUseCase>(),
        cache: ctx.read<AuthCacheDataSource>(),
        tokenHolder: ctx.read<TokenHolder>(),
        config: AuthConfig(inactivityTimeoutMinutes: 60),
      ),
    ),
  ];
}
