// [SWREQ-HW-SENSOR-001] [IEC 62304 §5.5]
// Yönetim kartı sensör yanıtlarını çözer.
//
// Kart, sensör satırı seçildiğinde doğrudan veri döner; ayrıca okuma
// komutu gerekmez. Yanıt formatı:
//
//   row 50 (ısı/nem)  →  +(30.0/60.0)-   → sıcaklık 30.0 °C, nem %60.0
//   row 49 (akü)      →  +(26.3)-        → 26.3 V
//
// Donanımda birebir doğrulandı (PowerShell probe, ham byte dökümü).
//
// Sınıf: Class B

class CabinSensorParser {
  const CabinSensorParser._();

  /// `+(...)-` sarmalayıcısının içindeki gövdeyi çıkarır.
  /// Format beklenenden farklıysa null döner — kısmi/bozuk yanıt
  /// sessizce yanlış değere dönüşmesin diye kesin eşleşme aranır.
  static String? _extractBody(String? response) {
    if (response == null) return null;

    final trimmed = response.trim();
    if (trimmed.isEmpty) return null;

    final match = RegExp(r'^\+\((.*)\)-$').firstMatch(trimmed);
    return match?.group(1);
  }

  /// Isı/nem yanıtını çözer: `+(30.0/60.0)-` → (temperature: 30.0, humidity: 60.0)
  ///
  /// Yanıt bozuksa, iki alandan biri parse edilemezse veya değerler
  /// makul aralığın dışındaysa null döner.
  static ({double temperature, double humidity})? parseTempHumidity(String? response) {
    final body = _extractBody(response);
    if (body == null) return null;

    final parts = body.split('/');
    if (parts.length != 2) return null;

    final temperature = double.tryParse(parts[0].trim());
    final humidity = double.tryParse(parts[1].trim());
    if (temperature == null || humidity == null) return null;

    // Aralık kontrolü — bozuk okuma (örn. sensör kopuk) uydurma değer üretmesin.
    if (!_isPlausibleTemperature(temperature)) return null;
    if (!_isPlausibleHumidity(humidity)) return null;

    return (temperature: temperature, humidity: humidity);
  }

  /// Akü yanıtını çözer: `+(26.3)-` → 26.3 (volt)
  ///
  /// Yanıt bozuksa veya değer makul voltaj aralığının dışındaysa null döner.
  static double? parseBattery(String? response) {
    final body = _extractBody(response);
    if (body == null) return null;

    // Akü yanıtında ayraç beklenmez; varsa format bozuk demektir.
    if (body.contains('/')) return null;

    final volts = double.tryParse(body.trim());
    if (volts == null) return null;

    if (!_isPlausibleVoltage(volts)) return null;

    return volts;
  }

  // ── Makuliyet kontrolleri ─────────────────────────────────────────
  // Sensör kopması / hat gürültüsü durumunda saçma değerlerin
  // dashboard'a ve (ileride) sunucu loguna geçmesini engeller.

  /// Kabin içi sıcaklık — geniş ama sonlu bir aralık.
  static bool _isPlausibleTemperature(double c) => c >= -40 && c <= 100;

  /// Bağıl nem yüzdesi.
  static bool _isPlausibleHumidity(double pct) => pct >= 0 && pct <= 100;

  /// LiFePO4 8S akü: nominal 25.6 V, max 29.6 V, min 21.2 V.
  /// Sınırların biraz dışına pay bırakılır (şarj/derin deşarj anları).
  static bool _isPlausibleVoltage(double v) => v >= 15 && v <= 35;
}