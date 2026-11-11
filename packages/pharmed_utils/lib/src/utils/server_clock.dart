// [SWREQ-CORE-007] [IEC 62304 §5.5]
// Sunucu saati — tarih filtreleri ve "bugün" hesabı için tek kaynak.
//
// Sorun: Tarih filtreleri (ör. "Bugün") cihazın saatiyle hesaplanıyordu.
// Saati ya da saat dilimi yanlış olan bir cihazda aralık kayıyor ve kayıtlar
// (ör. dolum bekleyen order'lar) gelmiyordu.
//
// Çözüm:
//   • Sunucu her yanıtta `Date` başlığıyla UTC saatini gönderir. Ağ katmanı
//     (ServerClockInterceptor) bunu [updateFromHttpDate] ile buraya verir;
//     cihaz ile sunucu arasındaki fark ([skew]) tutulur.
//   • Veritabanı tarihleri saat dilimi bilgisi olmadan hastane saatiyle tutar
//     (ör. "2026-11-03T11:40:19"). Hastane saat dilimi sabittir:
//     HOSPITAL_UTC_OFFSET_MINUTES (varsayılan 180 = Türkiye, UTC+3, yaz saati yok).
//   • [now] = sunucunun UTC saati + hastane farkı → saat dilimsiz "duvar saati".
//     Cihazın saati de saat dilimi de sonucu etkilemez.
//
// İlk yanıttan önce fark 0 kabul edilir (cihazın UTC saati + hastane farkı).
//
// Kullanım: Sorgu aralıkları ve "bugün" için DateTime.now() yerine
// ServerClock.now() / ServerClock.today(). Kayıt anı damgaları (ör. arıza
// başlangıcı) bu sınıfın kapsamında değildir.
//
// Sınıf: Class B

abstract final class ServerClock {
  static const int hospitalUtcOffsetMinutes = int.fromEnvironment(
    'HOSPITAL_UTC_OFFSET_MINUTES',
    defaultValue: 180,
  );

  static Duration _skew = Duration.zero;
  static bool _synced = false;

  /// Sunucu saati − cihaz saati (UTC). Pozitif → cihaz geride.
  static Duration get skew => _skew;

  /// En az bir yanıttan sunucu saati okundu mu?
  static bool get isSynced => _synced;

  /// HTTP `Date` başlığını (RFC 1123, ör. "Wed, 11 Nov 2026 13:01:00 GMT")
  /// okuyup farkı günceller. Okunamazsa hiçbir şey yapmaz. Yeni farkı döner.
  static Duration? updateFromHttpDate(String? header) {
    final serverUtc = _parseHttpDate(header);
    if (serverUtc == null) return null;
    _skew = serverUtc.difference(DateTime.now().toUtc());
    _synced = true;
    return _skew;
  }

  /// Hastane saatiyle şu an — saat dilimsiz (isUtc == false) DateTime.
  /// toIso8601String() "2026-11-11T16:00:00.000" üretir; veritabanı
  /// tarihleriyle doğrudan karşılaştırılabilir.
  static DateTime now() {
    final u = DateTime.now().toUtc().add(_skew).add(const Duration(minutes: hospitalUtcOffsetMinutes));
    return DateTime(u.year, u.month, u.day, u.hour, u.minute, u.second, u.millisecond, u.microsecond);
  }

  /// Hastane saatiyle bugünün başı (00:00).
  static DateTime today() {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Verilen günün sonu (23:59:59.999).
  static DateTime endOfDay(DateTime day) => DateTime(day.year, day.month, day.day, 23, 59, 59, 999);

  /// Testler için.
  static void resetForTest() {
    _skew = Duration.zero;
    _synced = false;
  }

  static const _months = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
    'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };

  static final _rfc1123 = RegExp(r'(\d{1,2}) ([A-Za-z]{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) GMT');

  static DateTime? _parseHttpDate(String? header) {
    if (header == null) return null;
    final m = _rfc1123.firstMatch(header);
    if (m == null) return null;
    final month = _months[m.group(2)!.toLowerCase()];
    if (month == null) return null;
    return DateTime.utc(
      int.parse(m.group(3)!),
      month,
      int.parse(m.group(1)!),
      int.parse(m.group(4)!),
      int.parse(m.group(5)!),
      int.parse(m.group(6)!),
    );
  }
}
