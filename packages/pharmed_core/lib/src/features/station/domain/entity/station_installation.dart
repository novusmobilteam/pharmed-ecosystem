// [SWREQ-SETUP-RESTORE-001] [IEC 62304 §5.5]
// Cihazın MAC adresine kayıtlı istasyon ve bağlı kabinler. Yerel kurulum kaydı
// silindiğinde kurulumun sihirbaz yapılmadan geri yüklenmesi için kullanılır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class InstalledCabin {
  const InstalledCabin({required this.cabin, this.hasDesign = true});

  final Cabin cabin;

  /// false → kabin oluşturulmuş ama çekmece tasarımı kaydedilmeden kurulum
  /// yarıda kalmış.
  final bool hasDesign;

  bool get isPrimary => cabin.no?.trim().toLowerCase() == 'a';
}

class StationInstallation {
  const StationInstallation({this.station, this.cabins = const []});

  static const empty = StationInstallation();

  final Station? station;

  /// `no`'ya göre sıralı; master ve slave kabinler birlikte.
  final List<InstalledCabin> cabins;

  /// Geri yüklenebilir bir kurulum var mı (istasyon + en az bir kabin).
  bool get isRestorable => station?.id != null && primaryCabin?.cabin.id != null;

  /// Bilgisayarın bağlı olduğu ana kabin (`no = a`). Adres gelmezse ilk kabin.
  InstalledCabin? get primaryCabin => cabins.where((c) => c.isPrimary).firstOrNull ?? cabins.firstOrNull;
}
