// pharmed-client/lib/core/hardware/printer/esc_pos_encoder.dart
//
// [SWREQ-PRN-020] [IEC 62304 §5.5]
// ESC/POS komut üretici (EM5820 / POS-58, 384 nokta).
//
// Neden metin değil bitmap:
//   EM5820 firmware'i Çince (GB18030) modda kilitli; FS . ile kapatılamıyor ve
//   hiçbir kod sayfası Türkçe karakterleri basmıyor. Bu yüzden tüm metin
//   ReceiptRasterizer'da görüntüye çevrilir ve burada GS v 0 ile gönderilir.
//   Barkodlar yalnızca ASCII içerdiğinden yazıcının yerel komutuyla basılır
//   (bitmap barkoddan daha keskin, okuyucu dostu).
//
// Sınıf: Class B

import 'dart:typed_data';

import 'package:pharmed_core/pharmed_core.dart';

/// 1-bit görüntü. Her satır [widthBytes] bayttır; bit 1 = siyah, MSB soldaki nokta.
final class MonoBitmap {
  const MonoBitmap({required this.widthBytes, required this.height, required this.bits})
    : assert(bits.length == widthBytes * height);

  final int widthBytes;
  final int height;
  final Uint8List bits;
}

/// Kodlanmış barkod parametreleri (yazıcıya gidecek veri + çubuk genişliği).
final class EncodedBarcode {
  const EncodedBarcode({required this.symbology, required this.payload, required this.moduleWidth});

  /// GS k m değeri: 67 = EAN-13, 73 = Code128.
  final int symbology;
  final Uint8List payload;
  final int moduleWidth;
}

class EscPosEncoder {
  const EscPosEncoder({this.paperWidthDots = 384, this.maxBandHeight = 255});

  final int paperWidthDots;

  /// Uzun görüntüler bu yükseklikte bantlara bölünür. Akış kontrolü olmayan
  /// yazıcıda tek parça büyük raster komutu tamponu taşırabiliyor.
  final int maxBandHeight;

  static const _esc = 0x1B;
  static const _gs = 0x1D;

  static const _symbologyEan13 = 67;
  static const _symbologyCode128 = 73;

  // ── Genel komutlar ──────────────────────────────────────────

  /// ESC @ — yazıcıyı sıfırla.
  List<int> initialize() => const [_esc, 0x40];

  /// ESC a n — hizalama (barkodlar için).
  List<int> align(ReceiptAlign align) => [
    _esc,
    0x61,
    switch (align) {
      ReceiptAlign.left => 0,
      ReceiptAlign.center => 1,
      ReceiptAlign.right => 2,
    },
  ];

  /// ESC d n — [lines] satır kâğıt ilerlet.
  List<int> feedLines(int lines) => [_esc, 0x64, lines.clamp(0, 255)];

  // ── Raster görüntü ─────────────────────────────────────────

  /// GS v 0 — görüntüyü [maxBandHeight] satırlık bantlar hâlinde basar.
  List<int> raster(MonoBitmap bitmap) {
    final out = <int>[];
    final xL = bitmap.widthBytes & 0xFF;
    final xH = (bitmap.widthBytes >> 8) & 0xFF;
    for (var top = 0; top < bitmap.height; top += maxBandHeight) {
      final h = (bitmap.height - top) < maxBandHeight ? bitmap.height - top : maxBandHeight;
      out
        ..addAll([_gs, 0x76, 0x30, 0x00, xL, xH, h & 0xFF, (h >> 8) & 0xFF])
        ..addAll(
          Uint8List.sublistView(bitmap.bits, top * bitmap.widthBytes, (top + h) * bitmap.widthBytes),
        );
    }
    return out;
  }

  // ── Barkod ─────────────────────────────────────────────────

  /// Barkodu yazıcının basabileceği biçime çevirir. Kâğıda sığmıyorsa ya da
  /// veri bu sembolojide kodlanamıyorsa null döner (çağıran metin olarak basar).
  EncodedBarcode? encodeBarcode(String data, ReceiptBarcodeType type) {
    final trimmed = data.trim();
    if (trimmed.isEmpty) return null;

    if (type == ReceiptBarcodeType.ean13) {
      final ean = normalizeEan13(trimmed);
      if (ean != null) {
        // 95 modül + sessiz bölge; 2 nokta/modül = 190 nokta, kâğıda rahat sığar.
        return EncodedBarcode(
          symbology: _symbologyEan13,
          payload: Uint8List.fromList(ean.codeUnits),
          moduleWidth: 2,
        );
      }
      // Geçersiz EAN → Code128 ile dene (fiş hiçbir zaman barkod yüzünden düşmesin).
    }
    return _encodeCode128(trimmed);
  }

  /// GS h / GS w / GS H / GS f + GS k — ortalanmış barkod, okunabilir metin altta.
  List<int> barcode(EncodedBarcode barcode, {required int height}) {
    return [
      ...align(ReceiptAlign.center),
      _gs, 0x68, height.clamp(1, 255), // yükseklik
      _gs, 0x77, barcode.moduleWidth, // çubuk genişliği
      _gs, 0x48, 0x02, // HRI altta
      _gs, 0x66, 0x00, // HRI font A
      _gs, 0x6B, barcode.symbology, barcode.payload.length,
      ...barcode.payload,
      0x0A,
      ...align(ReceiptAlign.left),
    ];
  }

  /// 12 haneye kontrol hanesi ekler; 13 haneyi doğrular. Geçersizse null.
  static String? normalizeEan13(String data) {
    if (!RegExp(r'^\d{12,13}$').hasMatch(data)) return null;
    final body = data.substring(0, 12);
    final full = '$body${ean13CheckDigit(body)}';
    if (data.length == 13 && data != full) return null;
    return full;
  }

  static int ean13CheckDigit(String twelveDigits) {
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      final d = twelveDigits.codeUnitAt(i) - 0x30;
      sum += i.isOdd ? d * 3 : d;
    }
    return (10 - sum % 10) % 10;
  }

  EncodedBarcode? _encodeCode128(String data) {
    // Code128 B: yazdırılabilir ASCII (32-126).
    if (data.codeUnits.any((c) => c < 32 || c > 126)) return null;

    // Tamamı rakam ve çift uzunluksa Code C (iki hane bir sembol) — yarı genişlik.
    final useSetC = data.length.isEven && RegExp(r'^\d+$').hasMatch(data);
    final symbols = useSetC ? data.length ~/ 2 : data.length;
    final payload = useSetC
        ? [
            0x7B, 0x43, // {C
            for (var i = 0; i < data.length; i += 2) int.parse(data.substring(i, i + 2)),
          ]
        : [0x7B, 0x42, ...data.codeUnits]; // {B

    if (payload.length > 255) return null;

    // start + veri + kontrol = 11'er modül, stop = 13 modül, iki yanda 10'ar modül sessiz bölge.
    final modules = 11 * (symbols + 2) + 13 + 20;
    final moduleWidth = modules * 2 <= paperWidthDots
        ? 2
        : modules <= paperWidthDots
        ? 1
        : 0;
    if (moduleWidth == 0) return null;

    return EncodedBarcode(
      symbology: _symbologyCode128,
      payload: Uint8List.fromList(payload),
      moduleWidth: moduleWidth,
    );
  }
}
