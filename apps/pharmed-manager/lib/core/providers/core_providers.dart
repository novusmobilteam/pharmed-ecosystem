// [SWREQ-NET-001]
// Ağ katmanı provider'ları.
// Circular dependency önlemi: APIManager → TokenHolder → token string
// AuthNotifier login/logout sonrası TokenHolder'ı günceller.
// Sınıf: Class B

import 'package:pharmed_manager/core/core.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cache/app_settings_cache.dart';
import '../services/rfid/rfid_service.dart';

class CoreProviders {
  static List<SingleChildWidget> providers({required SharedPreferences prefs}) {
    return [
      Provider<SharedPreferences>.value(value: prefs),
      Provider<TokenHolder>(create: (_) => TokenHolder()),
      Provider<IRfidService>(create: (_) => RfidService()),
      Provider(create: (context) => AppSettingsCache(context.read())),

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
}
