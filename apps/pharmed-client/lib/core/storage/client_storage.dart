// [SWREQ-CORE-005] [IEC 62304 §5.5]
// Yerel deponun (Hive) açılışı. Bütün main_*.dart dosyaları bunu kullanır.
//
// Test cihazı seçiliyse (yalnızca bilgisayar test sürümü) Hive o cihazın kendi
// klasöründe açılır; aksi halde varsayılan klasörde (eski davranış).
// Loglama kurulduktan sonra, runApp'ten önce çağrılır.
//
// Sınıf: Class B

import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';

import '../dev_identity/dev_device_identity.dart';

Future<void> initClientStorage() async {
  final devHiveDir = await DevDeviceIdentity.bootstrap();
  if (devHiveDir == null) {
    await Hive.initFlutter();
    return;
  }
  await Directory(devHiveDir).create(recursive: true);
  Hive.init(devHiveDir);
}
