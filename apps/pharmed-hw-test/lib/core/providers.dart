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

final tokenHolderProvider = Provider<TokenHolder>((ref) => TokenHolder());

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

final stationRepositoryProvider = Provider<IStationRepository>((ref) {
  return StationRepositoryImpl(
    dataSource: StationRemoteDataSource(apiManager: ref.read(apiManagerProvider)),
    mapper: StationMapper(),
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

// ── Oturum ────────────────────────────────────────────────────────

class SessionState {
  const SessionState({this.user, this.station, this.cabins = const [], this.port});

  final AppUser? user;
  final Station? station;
  final List<Cabin> cabins;
  final String? port;

  bool get isLoggedIn => user != null;

  SessionState copyWith({AppUser? user, Station? station, List<Cabin>? cabins, String? port, bool clearPort = false}) {
    return SessionState(
      user: user ?? this.user,
      station: station ?? this.station,
      cabins: cabins ?? this.cabins,
      port: clearPort ? null : (port ?? this.port),
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  void setUser(AppUser user) => state = SessionState(user: user);

  void setStation(Station station, List<Cabin> cabins) => state = state.copyWith(station: station, cabins: cabins);

  void setPort(String? port) => state = port == null ? state.copyWith(clearPort: true) : state.copyWith(port: port);

  void logout() => state = const SessionState();
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

/// Yönetim kartı adres harfi ('a'..'p') için kabin adı, istasyonda varsa.
String? cabinNameForAddress(List<Cabin> cabins, int addressIndex) {
  for (final c in cabins) {
    if (ManagementCard.indexFromAddressChar(c.no) == addressIndex) return c.name ?? 'Kabin';
  }
  return null;
}

String addressLabel(int addressIndex) => ManagementCard(addressIndex: addressIndex).addressChar.toUpperCase();
