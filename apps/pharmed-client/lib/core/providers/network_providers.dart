// [SWREQ-NET-001]
// Ağ katmanı provider'ları — pharmed-client.
// Circular dependency önlemi: APIManager → TokenHolder → token string
// AuthNotifier login/logout sonrası TokenHolder'ı günceller. 401 callback'i
// AuthNotifier kurulduktan SONRA, AuthProviders içinde bağlanır (bkz.
// auth_providers.dart) — bu dosya AuthNotifier'ı hiç bilmez.
// Sınıf: Class B

import 'package:dio/dio.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class NetworkProviders {
  static List<SingleChildWidget> providers() => [
    // Token interceptor'ı YOK — login/badge-login gibi henüz kimlik
    // doğrulanmamış isteklerde kullanılır (AuthRemoteDataSource).
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

    // ── TokenHolder ─────────────────────────────────────────────────
    //
    // Basit mutable container — APIManager ve AuthNotifier arasında köprü.
    // AuthNotifier login sonrası token'ı buraya yazar. TokenInterceptor
    // buradan sync okur. Circular dependency yok: APIManager → TokenHolder
    // (tek yön) — AuthNotifier'a bağımlılık burada YOK, callback kaydı
    // AuthProviders'da (AuthNotifier kurulduktan sonra) yapılır.
    Provider<TokenHolder>(create: (_) => TokenHolder()),

    // ── APIManager ──────────────────────────────────────────────────
    //
    // 401 callback'i burada BAĞLANMAZ — AuthNotifier henüz bu noktada
    // kurulmamış olabilir. Bağlama, AuthProviders.providers() listesindeki
    // AuthNotifier ChangeNotifierProvider'ının create: bloğunda yapılır.
    Provider<APIManager>(
      create: (ctx) {
        final config = FlavorConfig.instance;
        final tokenHolder = ctx.read<TokenHolder>();

        return APIManager(
          baseUrl: config.baseUrl,
          tokenProvider: tokenHolder,
          connectTimeout: Duration(milliseconds: config.connectTimeoutMs),
          receiveTimeout: Duration(milliseconds: config.receiveTimeoutMs),
        );
      },
    ),
  ];
}
