// [SWREQ-HW-TRAY-001] [IEC 62304 §5.5]
// Serum kabini avadanlık kilit kartı protokolü — saf (I/O'suz) komut üretimi
// ve yanıt ayrıştırma. Eski `:Y`/`:T` protokolünden (CommandBuilder) TAMAMEN
// ayrıdır; checksum yoktur.
//
//   Komut  (PC → kart):  <iXX:YZ>   XX = cihaz ID (01-99), Y = port (1-8), Z = komut
//   Yanıt  (kart → PC):  /xxxxx\
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Kilit kartı komut karakterleri.
enum TrayLockAction {
  /// Seçilen portun kilidini açar, DİĞER tüm portları kilitler.
  /// Yalnızca IDLE'da çalışır → STATE_UNLOCKED.
  open('o'),

  /// Açma işlemini iptal eder. Yalnızca UNLOCKED'da (henüz çekilmemişken) → IDLE.
  cancel('c'),

  /// Portun durumunu sorgular.
  status('s'),

  /// Port önündeki +/- panelinden girilen değeri okur (00-99).
  keypadValue('t'),

  /// Tüm kilitleri enerjiler (hepsini sabitler). STATE_OPEN'da çalışmaz → IDLE.
  lockAll('k'),

  /// Tüm kilitleri enerjisiz yapar (hepsini serbest bırakır). STATE_OPEN'da çalışmaz → IDLE.
  unlockAll('x');

  const TrayLockAction(this.code);

  final String code;

  /// Port parametresi anlamsız olan (tüm kartı etkileyen) komutlar.
  bool get isCardWide => this == lockAll || this == unlockAll;
}

/// `s` komutunun döndürdüğü port durumu.
enum TrayLockStatus {
  /// `/s:01\` — kilit açıldı, avadanlık henüz çekilmedi.
  unlocked,

  /// `/s:02\` — avadanlık çekildi, göz aktif (+/- yapılabilir).
  pulled,

  /// `/s:03\` — kapalı / idle.
  idle,
}

/// Ayrıştırılmış kart yanıtı.
sealed class TrayLockResponse {
  const TrayLockResponse();
}

final class TrayLockOk extends TrayLockResponse {
  const TrayLockOk();
}

final class TrayLockStatusResponse extends TrayLockResponse {
  const TrayLockStatusResponse(this.status);
  final TrayLockStatus status;
}

final class TrayLockKeypadResponse extends TrayLockResponse {
  const TrayLockKeypadResponse(this.value);
  final int value;
}

final class TrayLockErrorResponse extends TrayLockResponse {
  const TrayLockErrorResponse(this.failure);
  final TrayLockFailure failure;
}

abstract final class TrayLockProtocol {
  static const int minDeviceId = 1;
  static const int maxDeviceId = 99;
  static const int minPort = 1;
  static const int maxPort = 8;

  /// Kart geneli komutlarda (k/x) port alanına yazılan değer.
  static const int cardWidePort = 0;

  /// Kartın yanıt bitiş karakteri. SerialCommunicationService bunu da
  /// "yanıt tamamlandı" olarak tanımalıdır.
  static const String responseTerminator = r'\';

  /// `<iXX:YZ>` komutunu üretir. Geçersiz parametrede [ArgumentError].
  static String build({required int deviceId, required TrayLockAction action, int? port}) {
    if (deviceId < minDeviceId || deviceId > maxDeviceId) {
      throw ArgumentError.value(deviceId, 'deviceId', 'must be $minDeviceId-$maxDeviceId');
    }
    final p = action.isCardWide ? cardWidePort : port;
    if (p == null) throw ArgumentError.notNull('port');
    if (!action.isCardWide && (p < minPort || p > maxPort)) {
      throw ArgumentError.value(p, 'port', 'must be $minPort-$maxPort');
    }
    final id = deviceId.toString().padLeft(2, '0');
    return '<i$id:$p${action.code}>';
  }

  /// Ham yanıtı ayrıştırır. Yanıt yoksa [TrayLockFailure.noResponse],
  /// tanınmıyorsa [TrayLockFailure.protocolError] döner.
  ///
  /// Kart yanıtın başına/sonuna gürültü ekleyebileceği için `/…\` çerçevesi
  /// metnin içinde aranır.
  static TrayLockResponse parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const TrayLockErrorResponse(TrayLockFailure.noResponse);

    final match = RegExp(r'/([^/\\]+)\\').firstMatch(raw);
    if (match == null) return const TrayLockErrorResponse(TrayLockFailure.protocolError);
    final body = match.group(1)!;

    switch (body) {
      case 'okkk':
        return const TrayLockOk();
      case 'noo1':
        return const TrayLockErrorResponse(TrayLockFailure.invalidDeviceId);
      case 'noo2':
        return const TrayLockErrorResponse(TrayLockFailure.trayOpen);
      case 'noo3':
        return const TrayLockErrorResponse(TrayLockFailure.invalidPort);
      case 'noo4':
        return const TrayLockErrorResponse(TrayLockFailure.busy);
      case 'noo5':
        return const TrayLockErrorResponse(TrayLockFailure.alreadyPulled);
      case 'noo6':
        return const TrayLockErrorResponse(TrayLockFailure.unknownCommand);
      case 's:01':
        return const TrayLockStatusResponse(TrayLockStatus.unlocked);
      case 's:02':
        return const TrayLockStatusResponse(TrayLockStatus.pulled);
      case 's:03':
        return const TrayLockStatusResponse(TrayLockStatus.idle);
    }

    final keypad = RegExp(r'^t:(\d{2})$').firstMatch(body);
    if (keypad != null) return TrayLockKeypadResponse(int.parse(keypad.group(1)!));

    // Dokümante edilmemiş genel hata (`/nooo\`) dahil.
    return const TrayLockErrorResponse(TrayLockFailure.protocolError);
  }
}
