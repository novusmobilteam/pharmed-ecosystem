// [SWREQ-UI-AUTH-001]
// Auth katmanı provider'ları — pharmed-client.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_client/core/flavor/auth_config.dart';
import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/auth/notifier/auth_notifier.dart';

class AuthProviders {
  static List<SingleChildWidget> providers() => [
    Provider<AuthConfig>(create: (_) => AuthConfig(inactivityTimeoutMinutes: 5, warningSeconds: 60)),

    Provider<AuthCacheDataSource>(create: (_) => AuthCacheDataSource(boxPrefix: 'client_')),
    Provider<AuthRemoteDataSource>(create: (ctx) => AuthRemoteDataSource(dio: ctx.read())),

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
    Provider<LoginWithBadgeUseCase>(create: (ctx) => LoginWithBadgeUseCase(ctx.read<IAuthRepository>())),
    Provider<LogoutUseCase>(create: (ctx) => LogoutUseCase(ctx.read<IAuthRepository>())),

    ChangeNotifierProvider<AuthNotifier>(
      create: (ctx) {
        final notifier = AuthNotifier(
          config: ctx.read<AuthConfig>(),
          loginUseCase: ctx.read<LoginUseCase>(),
          loginWithBadge: ctx.read<LoginWithBadgeUseCase>(),
          logoutUseCase: ctx.read<LogoutUseCase>(),
          cache: ctx.read<AuthCacheDataSource>(),
          tokenHolder: ctx.read<TokenHolder>(),
          appSettingsCache: ctx.read<AppSettingsCache>(),
        );
        // 401 callback'i — APIManager zaten NetworkProviders'da TokenHolder
        // ile kuruldu, burada TokenHolder'a "kim dinleyecek" bilgisini
        // veriyoruz. AuthNotifier kurulduktan hemen sonra, tek noktada.
        ctx.read<TokenHolder>().setOnUnauthorized(notifier.onUnauthorized);
        return notifier;
      },
    ),
  ];
}
