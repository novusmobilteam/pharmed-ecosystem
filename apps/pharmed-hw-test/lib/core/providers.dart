// Bağımlılıklar: ağ + giriş + kabin tanımları (pharmed_data) ve donanım
// (pharmed_hardware). Client ile aynı repository ve servis sınıfları kullanılır.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_hardware/pharmed_hardware.dart';

import 'env.dart';
import 'report.dart';
import 'traffic_log.dart';

// ── Ağ ve giriş ───────────────────────────────────────────────────

final tokenHolderProvider = Provider<TokenHolder>((ref) {
  final holder = TokenHolder();
  // [SWREQ-DATA-AUTH-005] 401 → refresh token ile oturumu yenile, isteği tekrar dene.
  // Lazy: authRepository yalnızca refresh anında okunur.
  holder.setRefreshHandler(() async => (await ref.read(authRepositoryProvider).refreshSession()).isSuccess);
  return holder;
});

final apiManagerProvider = Provider<APIManager>((ref) {
  return APIManager(
    baseUrl: AppEnv.instance.baseUrl,
    tokenProvider: ref.read(tokenHolderProvider),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  );
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final plainDio = Dio(
    BaseOptions(
      baseUrl: AppEnv.instance.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(dio: plainDio),
    cacheDataSource: AuthCacheDataSource(boxPrefix: 'hwtest_'),
    userReader: UserRepositoryImpl(
      dataSource: UserRemoteDataSource(apiManager: ref.read(apiManagerProvider)),
      mapper: const UserMapper(),
    ),
    tokenHolder: ref.read(tokenHolderProvider),
  );
});

final cabinRepositoryProvider = Provider<ICabinRepository>((ref) {
  return CabinRepositoryImpl(
    cabinMapper: CabinMapper(),
    drawerSlotMapper: DrawerSlotMapper(),
    drawerConfigMapper: DrawerConfigMapper(),
    drawerUnitMapper: DrawerUnitMapper(),
    drawerTypeMapper: DrawerTypeMapper(),
    mobileDrawerSlotMapper: MobileDrawerSlotMapper(),
    remoteDataSource: CabinRemoteDataSource(apiManager: ref.read(apiManagerProvider)),
    localDataSource: CabinLocalDataSource(),
  );
});

// ── Donanım ───────────────────────────────────────────────────────

final trafficLogProvider = ChangeNotifierProvider<TrafficLog>((ref) => TrafficLog());

final testReportProvider = ChangeNotifierProvider<TestReport>((ref) => TestReport());

/// Gerçek seri servis, trafik kaydı yapan sarmalayıcıyla.
final serialServiceProvider = Provider<ISerialCommunicationService>((ref) {
  return LoggingSerialService(SerialCommunicationService(), ref.read(trafficLogProvider));
});

/// Client'taki ile aynı kabin kartı servisi (satır seçimi, tarama, açma, durum).
final cabinOpsProvider = Provider<ICabinOperationService>((ref) {
  return CabinOperationService(
    serialService: ref.read(serialServiceProvider),
    readSavedComPort: () async => ref.read(sessionProvider).port,
  );
});

/// UHFEx10 RFID okuyucu (TCP) — client ile aynı servis.
final rfidServiceProvider = Provider<IRfidService>((ref) => RfidService());

// ── Oturum ────────────────────────────────────────────────────────

class SessionState {
  const SessionState({this.user, this.port});

  final AppUser? user;

  /// Bağlı COM port; null ise bağlı değil.
  final String? port;

  bool get isLoggedIn => user != null;
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  void setUser(AppUser user) => state = SessionState(user: user);

  void setPort(String? port) => state = SessionState(user: state.user, port: port);

  void logout() => state = const SessionState();
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

String addressLabel(int addressIndex) => ManagementCard(addressIndex: addressIndex).addressChar.toUpperCase();
