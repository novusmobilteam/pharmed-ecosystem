// pharmed_core/lib/src/services/printer/receipt_document.dart
//
// [SWREQ-PRN-001] [IEC 62304 §5.5]
// Yazıcıdan ve ekrandan bağımsız fiş modeli.
//
// Ekranlar fişi yalnızca bu bloklarla tarif eder; ESC/POS, kâğıt genişliği,
// font ve kod sayfası gibi donanım ayrıntılarını bilmez. Blokların fiziksel
// çıktıya çevrilmesi IReceiptPrinter uygulamasının işidir.
//
// Sınıf: Class B

/// Yazdırılacak fiş. [blocks] yukarıdan aşağıya sırayla basılır.
final class ReceiptDocument {
  const ReceiptDocument({required this.title, required this.blocks});

  /// Log ve yazıcı kuyruğunda görünen ad (örn. "Alım Fişi"). Fişe basılmaz.
  final String title;

  final List<ReceiptBlock> blocks;

  bool get isEmpty => blocks.isEmpty;
}

enum ReceiptAlign { left, center, right }

/// Metin boyutu. Piksel karşılıkları yazıcı uygulamasında tanımlıdır.
enum ReceiptTextSize {
  /// Dipnot, konum bilgisi gibi ikincil satırlar.
  small,

  /// Gövde metni.
  normal,

  /// Bölüm başlığı, hasta adı.
  large,

  /// Fişin en üstündeki ana başlık.
  title,
}

enum ReceiptDividerStyle { solid, thick, dashed }

enum ReceiptBarcodeType {
  /// Alfanümerik veri (protokol no, hasta barkodu vb.).
  code128,

  /// 12 veya 13 haneli ürün barkodu. 12 hane verilirse kontrol hanesi hesaplanır.
  /// Geçersiz veri Code128 olarak basılır.
  ean13,
}

sealed class ReceiptBlock {
  const ReceiptBlock();
}

/// Bir veya birden fazla satıra kaydırılan metin.
final class ReceiptText extends ReceiptBlock {
  const ReceiptText(
    this.text, {
    this.size = ReceiptTextSize.normal,
    this.bold = false,
    this.align = ReceiptAlign.left,
    this.indent = 0,
  });

  final String text;
  final ReceiptTextSize size;
  final bool bold;
  final ReceiptAlign align;

  /// Sol girinti, karakter genişliği cinsinden değil piksel (nokta) cinsinden.
  final int indent;
}

/// Solda etiket, sağda değer. Sığmazsa değer bir alt satıra sağa yaslı geçer.
final class ReceiptKeyValue extends ReceiptBlock {
  const ReceiptKeyValue(
    this.label,
    this.value, {
    this.size = ReceiptTextSize.normal,
    this.bold = false,
    this.indent = 0,
  });

  final String label;
  final String value;
  final ReceiptTextSize size;
  final bool bold;
  final int indent;
}

final class ReceiptDivider extends ReceiptBlock {
  const ReceiptDivider([this.style = ReceiptDividerStyle.solid]);

  final ReceiptDividerStyle style;
}

/// Dikey boşluk (nokta cinsinden; 8 nokta ≈ 1 mm).
final class ReceiptSpacer extends ReceiptBlock {
  const ReceiptSpacer([this.height = 8]);

  final int height;
}

/// Ortalanmış barkod; okunabilir metni altında basılır.
final class ReceiptBarcode extends ReceiptBlock {
  const ReceiptBarcode(this.data, {this.type = ReceiptBarcodeType.code128, this.height = 60});

  final String data;
  final ReceiptBarcodeType type;

  /// Çubuk yüksekliği (nokta cinsinden).
  final int height;
}
