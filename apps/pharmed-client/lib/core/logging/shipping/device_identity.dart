// [SWREQ-NET-007] Kioskun kalıcı kimliği ve bu açılışın kimliği.
//
// deviceId ilk açılışta üretilir ve <veri kökü>/device-id dosyasında saklanır;
// uygulama güncellense de değişmez. appRunId her açılışta yenidir — istek
// korelasyon id'leri (r1, r2…) yalnızca bir açılış içinde tekil olduğu için
// backend istek izini appRunId + req ile arar.

import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;

final _random = Random.secure();

/// RFC 4122 v4 GUID.
String uuidV4() {
  final b = List<int>.generate(16, (_) => _random.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
}

final _guid = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

class DeviceIdentity {
  const DeviceIdentity({
    required this.deviceId,
    required this.hostName,
    required this.os,
    required this.appVersion,
    required this.flavor,
  });

  final String deviceId;
  final String hostName;
  final String os;
  final String appVersion;
  final String flavor;

  /// Dosyadan okur; yoksa ya da bozuksa yenisini üretip yazar.
  static DeviceIdentity load({required String dataRoot, required String appVersion, required String flavor}) {
    final file = File(p.join(dataRoot, 'device-id'));
    String? id;
    try {
      if (file.existsSync()) {
        final text = file.readAsStringSync().trim();
        if (_guid.hasMatch(text)) id = text;
      }
    } catch (_) {}
    if (id == null) {
      id = uuidV4();
      try {
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(id, flush: true);
      } catch (_) {
        // Yazılamazsa bu açılış için geçici id ile devam edilir.
      }
    }
    return DeviceIdentity(
      deviceId: id,
      hostName: Platform.localHostname,
      os: Platform.operatingSystemVersion,
      appVersion: appVersion,
      flavor: flavor,
    );
  }

  Map<String, dynamic> toJson({int? stationId}) => {
    'deviceId': deviceId,
    'hostName': hostName,
    'stationId': stationId,
    'appVersion': appVersion,
    'flavor': flavor,
    'os': os,
  };
}
