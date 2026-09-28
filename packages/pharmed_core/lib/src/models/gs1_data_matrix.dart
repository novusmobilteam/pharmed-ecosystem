// [SWREQ-CORE-GS1-001] [IEC 62304 §5.5]
// İTS karekodu (GS1 DataMatrix) çözümleyici. Saf Dart — Flutter bağımlılığı yok.
//
// Desteklenen biçimler:
//   1) Ham okuyucu çıktısı, değişken alanlar GS (0x1D) ile ayrılmış:
//        0108699514090138 21A7K3M9Q2X4 <GS> 17280630 10L24081
//   2) İnsan okunur, parantezli:
//        (01)08699514090138(21)A7K3M9Q2X4(17)280630(10)L24081
//   3) Ham çıktı, GS KAYBOLMUŞ (bazı klavye-emülasyonlu okuyucular GS'i
//      iletmez): değişken alanın sonu, arkasından gelen geçerli bir (17)
//      tarihine göre TAHMİN edilir → [Gs1Code.isHeuristic] true.
//
// Symbology öneki (]d2, ]Q3, ]C1) varsa atılır.
//
// Sınıf: Class B

/// Çözümlenmiş karekod. Çözümlenemeyen alanlar null'dır; [raw] her zaman
/// okuyucudan gelen değerin kendisidir (backend'e bu gönderilir).
class Gs1Code {
  const Gs1Code({
    required this.raw,
    this.gtin,
    this.serial,
    this.expiry,
    this.lot,
    this.isHeuristic = false,
    this.rawGtin,
  });

  final String raw;

  /// 14 haneli, kontrol hanesi doğrulanmış GTIN (AI 01).
  final String? gtin;

  /// Seri no (AI 21) — İTS'de her kutuya özgü.
  final String? serial;

  /// Son kullanma tarihi (AI 17). Gün 00 ise ayın son günü.
  final DateTime? expiry;

  /// Parti/lot no (AI 10).
  final String? lot;

  /// Değişken alan sınırı GS olmadan tahmin edildi.
  final bool isHeuristic;

  /// AI 01'den okunan ham 14 hane — kontrol hanesi tutmasa bile dolu.
  /// [gtin] ile farklıysa kontrol hanesi geçersizdir (teşhis için).
  final String? rawGtin;

  bool get hasGtin => gtin != null;

  /// Tekrar tespiti anahtarı: GTIN + seri no; seri çözülemediyse ham içerik.
  String get identity => (gtin != null && serial != null) ? '$gtin|$serial' : raw.trim();

  bool get hasInvalidCheckDigit => rawGtin != null && gtin == null;
}

abstract final class Gs1DataMatrix {
  static const String groupSeparator = '\u001D';

  /// Sabit uzunluklu AI'lar (değer uzunluğu).
  static const Map<String, int> _fixedLength = {
    '00': 18,
    '01': 14,
    '02': 14,
    '11': 6,
    '12': 6,
    '13': 6,
    '15': 6,
    '16': 6,
    '17': 6,
    '20': 2,
  };

  /// Bilinen değişken uzunluklu 2 haneli AI'lar ve azami uzunlukları.
  static const Map<String, int> _variableMaxLength = {'10': 20, '21': 20, '22': 20, '30': 8, '37': 8};

  static final RegExp _symbologyPrefix = RegExp(r'^\][A-Za-z]\d');
  static final RegExp _parenthesizedField = RegExp(r'\((\d{2,4})\)([^()]*)');

  static Gs1Code parse(String input) {
    var s = input.trim().replaceFirst(_symbologyPrefix, '');
    if (s.startsWith(groupSeparator)) s = s.substring(1);

    final (fields, isHeuristic) = s.contains('(') ? (_parseParenthesized(s), false) : _parseRaw(s);

    final gtin = fields['01'];
    return Gs1Code(
      raw: input.trim(),
      rawGtin: gtin,
      gtin: gtin != null && isValidGtin(gtin) ? gtin : null,
      serial: _nonEmpty(fields['21']),
      expiry: _parseDate(fields['17']),
      lot: _nonEmpty(fields['10']),
      isHeuristic: isHeuristic,
    );
  }

  /// Karşılaştırma için 14 haneye tamamlar (EAN-13 → GTIN-14). Rakam dışı
  /// karakter içeriyorsa ya da 14'ten uzunsa null.
  static String? normalizeGtin(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty || v.length > 14 || !RegExp(r'^\d+$').hasMatch(v)) return null;
    return v.padLeft(14, '0');
  }

  /// GS1 mod-10 kontrol hanesi doğrulaması.
  static bool isValidGtin(String gtin) {
    if (!RegExp(r'^\d{14}$').hasMatch(gtin)) return false;
    var sum = 0;
    for (var i = 0; i < 13; i++) {
      final d = gtin.codeUnitAt(i) - 48;
      sum += (i.isEven ? 3 : 1) * d;
    }
    final check = (10 - sum % 10) % 10;
    return check == gtin.codeUnitAt(13) - 48;
  }

  // ── Biçim 2: parantezli ────────────────────────────────────────────────

  static Map<String, String> _parseParenthesized(String s) => {
    for (final m in _parenthesizedField.allMatches(s)) m.group(1)!: m.group(2)!.replaceAll(groupSeparator, ''),
  };

  // ── Biçim 1 ve 3: ham ──────────────────────────────────────────────────

  static (Map<String, String>, bool) _parseRaw(String s) {
    final fields = <String, String>{};
    final hasSeparator = s.contains(groupSeparator);
    var heuristic = false;
    var i = 0;

    while (i < s.length) {
      if (s[i] == groupSeparator) {
        i++;
        continue;
      }
      if (i + 2 > s.length) break;
      final ai = s.substring(i, i + 2);

      final fixed = _fixedLength[ai];
      if (fixed != null) {
        final end = i + 2 + fixed;
        if (end > s.length) break;
        fields[ai] = s.substring(i + 2, end);
        i = end;
        continue;
      }

      final maxLength = _variableMaxLength[ai];
      if (maxLength != null) {
        final start = i + 2;
        var end = s.indexOf(groupSeparator, start);
        if (end < 0) {
          end = s.length;
          if (!hasSeparator) {
            final guessed = _guessVariableEnd(s, start, maxLength);
            if (guessed != null) {
              end = guessed;
              heuristic = true;
            }
          }
        }
        fields[ai] = s.substring(start, end);
        i = end;
        continue;
      }

      // Bilinmeyen AI — kalan kısım güvenle çözümlenemez.
      break;
    }
    return (fields, heuristic);
  }

  /// GS yokken değişken alanın bittiği yeri tahmin eder: alanın içinde,
  /// geçerli bir YYMMDD taşıyan "17" ve ardından metin sonu ya da "10"/"21"
  /// gelen ilk konum. İTS karekodlarındaki olağan (21)(17)(10) sırasına göre.
  static int? _guessVariableEnd(String s, int start, int maxLength) {
    final upper = s.length - 8;
    if (upper < start + 1) return null;
    final last = start + maxLength < upper ? start + maxLength : upper;
    for (var j = start + 1; j <= last; j++) {
      if (!s.startsWith('17', j)) continue;
      if (_parseDate(s.substring(j + 2, j + 8)) == null) continue;
      final after = j + 8;
      if (after == s.length || s.startsWith('10', after) || s.startsWith('21', after)) return j;
    }
    return null;
  }

  static DateTime? _parseDate(String? yymmdd) {
    if (yymmdd == null || !RegExp(r'^\d{6}$').hasMatch(yymmdd)) return null;
    final year = 2000 + int.parse(yymmdd.substring(0, 2));
    final month = int.parse(yymmdd.substring(2, 4));
    final day = int.parse(yymmdd.substring(4, 6));
    if (month < 1 || month > 12) return null;
    final lastDay = DateTime(year, month + 1, 0).day;
    if (day > lastDay) return null;
    return DateTime(year, month, day == 0 ? lastDay : day);
  }

  static String? _nonEmpty(String? v) => (v == null || v.isEmpty) ? null : v;
}
