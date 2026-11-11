// [SWREQ-CORE-005] [IEC 62304 §5.5]
// Test cihazı kimliği — yalnızca bilgisayarda (sahte donanımla) test için.
//
// Backend istasyonu cihaz kimliğiyle (DeviceInfo.getMacAddress) eşleştirir;
// bir kimliğe tek kabin kurulabilir. Aynı bilgisayarda birden çok kabini
// (ilaç bazlı, hasta bazlı/mobil, …) denemek için her "test cihazı" kendi
// sahte kimliğiyle ve KENDİ yerel deposuyla (Hive klasörü) çalışır: kurulum
// durumu, kabin cache'i, oturum, kayıt kuyruğu vb. cihazlar arasında karışmaz.
//
// Kural (değiştirilemez):
//   • Yalnızca HARDWARE=mock ve flavor != prod iken çalışır. Gerçek kabin
//     sürümünde (dev-kabin) ve prod'da kimlik HER ZAMAN donanımdan okunur;
//     testçi sahadaki kabinin tipini/kimliğini buradan değiştiremez.
//   • Kimlik açılışta, Hive'dan önce bir kez belirlenir; çalışırken değişmez.
//     Seçim değişince uygulama kapanır, yeniden açılışta yeni kimlik geçerlidir.
//   • "Bu bilgisayar" (activeId == null) eski davranıştır: fiziksel kimlik,
//     varsayılan Hive klasörü — mevcut kurulum olduğu gibi kalır.
//
// Öncelik: --dart-define=PHARMED_DEVICE_ID → kayıtlı seçim → fiziksel kimlik.
//
// Kayıtlar: <pharmedDataRoot>/dev-devices/registry.json
// Depo   : <pharmedDataRoot>/dev-devices/<profilId>/hive/
//
// Sınıf: Class B

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../flavor/app_flavor.dart';
import '../hardware/hardware_mode.dart';
import '../storage/app_data_paths.dart';

const _unit = 'SW-UNIT-DEV-IDENTITY';
const _swreq = 'SWREQ-CORE-005';

/// Bir test cihazı: adı, backend'e gönderilen sahte kimliği ve depo klasörü.
class DevDeviceProfile {
  const DevDeviceProfile({required this.id, required this.name, required this.deviceId, required this.createdAt});

  /// Klasör adı olarak da kullanılır (`pc-1`, `pc-2`, `define-…`).
  final String id;

  /// Testçinin verdiği ad: "Master 2", "Mobil kabin", …
  final String name;

  /// Backend'e cihaz kimliği olarak giden değer. Sahte olduğu bir bakışta
  /// anlaşılsın diye `PCTEST-` ile başlar.
  final String deviceId;

  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'deviceId': deviceId,
    'createdAt': createdAt.toIso8601String(),
  };

  static DevDeviceProfile? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'], name = json['name'], deviceId = json['deviceId'];
    if (id is! String || name is! String || deviceId is! String) return null;
    return DevDeviceProfile(
      id: id,
      name: name,
      deviceId: deviceId,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// registry.json içeriği.
class DevDeviceRegistry {
  const DevDeviceRegistry({this.activeId, this.profiles = const []});

  /// null → "Bu bilgisayar" (fiziksel kimlik).
  final String? activeId;
  final List<DevDeviceProfile> profiles;

  DevDeviceProfile? get active => profiles.firstWhereOrNull((e) => e.id == activeId);

  DevDeviceRegistry copyWith({String? activeId, bool clearActive = false, List<DevDeviceProfile>? profiles}) {
    return DevDeviceRegistry(
      activeId: clearActive ? null : (activeId ?? this.activeId),
      profiles: profiles ?? this.profiles,
    );
  }

  Map<String, dynamic> toJson() => {'activeId': activeId, 'profiles': profiles.map((e) => e.toJson()).toList()};

  factory DevDeviceRegistry.fromJson(Object? json) {
    if (json is! Map) return const DevDeviceRegistry();
    final profiles = (json['profiles'] as List? ?? const []).map(DevDeviceProfile.fromJson).nonNulls.toList();
    final activeId = json['activeId'] as String?;
    return DevDeviceRegistry(
      // Kaydı silinmiş bir profile işaret ediyorsa fiziksel kimliğe düş.
      activeId: profiles.any((e) => e.id == activeId) ? activeId : null,
      profiles: profiles,
    );
  }
}

abstract final class DevDeviceIdentity {
  static const _defineDeviceId = String.fromEnvironment('PHARMED_DEVICE_ID');
  static const _defineDeviceName = String.fromEnvironment('PHARMED_DEVICE_NAME');

  static DevDeviceProfile? _active;
  static bool _bootstrapped = false;

  /// Bu sürümde test cihazı seçilebilir mi? Yalnızca bilgisayar test sürümü.
  static bool get isAvailable => HardwareConfig.isMock && !FlavorConfig.instance.isProd;

  /// Kimlik derleme ayarıyla sabitlendiyse ekrandan değiştirilemez.
  static bool get isPinnedByDefine => isAvailable && _defineDeviceId.isNotEmpty;

  /// Bu oturumda kullanılan test cihazı. null → fiziksel kimlik.
  static DevDeviceProfile? get active => _active;

  static String get _root => p.join(pharmedDataRoot(), 'dev-devices');
  static File get _registryFile => File(p.join(_root, 'registry.json'));

  static String hiveDirectoryFor(DevDeviceProfile profile) => p.join(_root, profile.id, 'hive');

  /// `main`'de, loglama kurulduktan sonra ve Hive'dan ÖNCE bir kez çağrılır.
  /// Test cihazı seçiliyse kimliği DeviceInfo'ya verir ve o cihazın Hive
  /// klasörünü döndürür; aksi halde null (varsayılan Hive klasörü).
  static Future<String?> bootstrap() async {
    assert(!_bootstrapped, 'DevDeviceIdentity.bootstrap() bir kez çağrılır');
    _bootstrapped = true;
    _active = null;
    DeviceInfo.setIdentityOverride(null);

    if (!isAvailable) {
      if (_defineDeviceId.isNotEmpty) {
        MedLogger.warn(
          unit: _unit,
          swreq: _swreq,
          message: 'PHARMED_DEVICE_ID bu sürümde yok sayıldı (yalnızca bilgisayar test sürümü)',
          context: {'variant': HardwareConfig.variant},
        );
      }
      return null;
    }

    final DevDeviceProfile? profile;
    if (_defineDeviceId.isNotEmpty) {
      profile = DevDeviceProfile(
        id: 'define-${_slug(_defineDeviceId)}',
        name: _defineDeviceName.isNotEmpty ? _defineDeviceName : _defineDeviceId,
        deviceId: _defineDeviceId,
        createdAt: DateTime.now(),
      );
    } else {
      profile = (await loadRegistry()).active;
    }

    if (profile == null) {
      MedLogger.info(unit: _unit, swreq: _swreq, message: 'Test cihazı: bu bilgisayar (fiziksel kimlik)');
      return null;
    }

    _active = profile;
    DeviceInfo.setIdentityOverride(profile.deviceId);
    final hiveDir = hiveDirectoryFor(profile);
    MedLogger.info(
      unit: _unit,
      swreq: _swreq,
      message: 'Test cihazı kimliği aktif',
      context: {'name': profile.name, 'deviceId': profile.deviceId, 'pinned': isPinnedByDefine, 'hive': hiveDir},
    );
    return hiveDir;
  }

  /// Kayıtları okur. Dosya yoksa ya da bozuksa boş kayıt döner (hata fırlatmaz).
  static Future<DevDeviceRegistry> loadRegistry() async {
    try {
      final file = _registryFile;
      if (!await file.exists()) return const DevDeviceRegistry();
      return DevDeviceRegistry.fromJson(jsonDecode(await file.readAsString()));
    } catch (e) {
      MedLogger.warn(unit: _unit, swreq: _swreq, message: 'Test cihazı kayıtları okunamadı', context: {'error': '$e'});
      return const DevDeviceRegistry();
    }
  }

  static Future<void> _saveRegistry(DevDeviceRegistry registry) async {
    final file = _registryFile;
    await file.parent.create(recursive: true);
    // Önce geçici dosyaya yaz, sonra taşı: yarım yazılmış kayıt kalmasın.
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(const JsonEncoder.withIndent('  ').convert(registry.toJson()), flush: true);
    await tmp.rename(file.path);
  }

  /// Yeni test cihazı ekler (aktif yapmaz).
  ///
  /// [deviceId] boşsa yeni bir `PCTEST-…` kimliği üretilir. Doluysa o kimlik
  /// kullanılır (ör. backend'de zaten kayıtlı bir kabine bağlanmak için);
  /// aynı kimlik iki profilde olamaz.
  static Future<DevDeviceProfile> createProfile(String name, {String? deviceId}) async {
    _assertWritable();
    final registry = await loadRegistry();
    final customId = deviceId?.trim() ?? '';
    if (customId.isNotEmpty && registry.profiles.any((e) => e.deviceId == customId)) {
      throw StateError('Bu kimlikte bir test cihazı zaten var');
    }
    final used = registry.profiles.map((e) => e.id).toSet();
    var n = registry.profiles.length + 1;
    while (used.contains('pc-$n')) {
      n++;
    }
    final profile = DevDeviceProfile(
      id: 'pc-$n',
      name: name.trim().isEmpty ? 'Test cihazı $n' : name.trim(),
      deviceId: customId.isNotEmpty ? customId : _generateDeviceId(),
      createdAt: DateTime.now(),
    );
    await _saveRegistry(registry.copyWith(profiles: [...registry.profiles, profile]));
    MedLogger.info(
      unit: _unit,
      swreq: _swreq,
      message: 'Test cihazı eklendi',
      context: {'name': profile.name, 'deviceId': profile.deviceId},
    );
    return profile;
  }

  /// Bir sonraki açılışta kullanılacak cihazı kaydeder. null → bu bilgisayar.
  static Future<void> selectForNextLaunch(String? profileId) async {
    _assertWritable();
    final registry = await loadRegistry();
    await _saveRegistry(
      profileId == null ? registry.copyWith(clearActive: true) : registry.copyWith(activeId: profileId),
    );
    MedLogger.info(
      unit: _unit,
      swreq: _swreq,
      message: 'Test cihazı değişti, uygulama yeniden başlatılacak',
      context: {'from': _active?.id, 'to': profileId},
    );
  }

  static void _assertWritable() {
    if (!isAvailable || isPinnedByDefine) {
      throw StateError('Test cihazı bu sürümde değiştirilemez');
    }
  }

  /// `PCTEST-XXXXXXXX-XXXX-XXXX` — backend listelerinde sahte olduğu belli olur.
  static String _generateDeviceId() {
    final r = Random.secure();
    String hex(int len) => List.generate(len, (_) => r.nextInt(16).toRadixString(16)).join().toUpperCase();
    return 'PCTEST-${hex(8)}-${hex(4)}-${hex(4)}';
  }

  static String _slug(String value) {
    final s = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
    return s.isEmpty ? 'device' : s;
  }
}
