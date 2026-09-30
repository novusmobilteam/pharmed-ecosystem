// pharmed_core/features/refund/refund_qr_code_matcher.dart
// [SWREQ-CORE-MREFUND-020] [IEC 62304 §5.5]
//
// İade öncesi okutulan karekodları, alım sırasında okutulup kaydedilen
// karekodlarla (CabinTargetedPrescriptionItem.intakeQrCodes) karşılaştırır.
//
// Eşleşme anahtarı Gs1Code.identity (GTIN + seri no) — QrScanController'ın
// tekrar tespitinde kullandığı anahtarla aynı. SKT ve parti karşılaştırmaya
// katılmaz; aynı kutunun farklı biçimlendirilmiş okumaları eşleşmeli.
//
// Adet ve tekrar kontrolü QrScanDialog'da yapılır (allowPartialSubmit=false,
// aynı kutu iki kez eklenemez) — burada yalnızca "bu kutu bu kalemin
// alımında okutuldu mu" sorusu cevaplanır.
//
// Şimdilik yalnızca istemci tarafı doğrulama — okutulan kodlar backend'e
// gönderilmez.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class RefundQrCodeMatcher {
  RefundQrCodeMatcher(Iterable<String> intakeCodes)
    : _allowed = {
        for (final raw in intakeCodes)
          if (_identityOf(raw) case final id?) id,
      };

  final Set<Object> _allowed;

  /// Alımda okutulmuş, çözümlenebilen farklı kutu sayısı — okutulabilecek
  /// en fazla adet.
  int get availableCount => _allowed.length;

  bool matches(Gs1Code code) => _allowed.contains(code.identity);

  /// Alımda okutulmamış ilk kod; hepsi eşleşiyorsa null.
  Gs1Code? firstUnmatched(List<Gs1Code> codes) {
    for (final code in codes) {
      if (!matches(code)) return code;
    }
    return null;
  }

  /// GTIN veya seri no çözümlenemeyen kayıt eşleşme kümesine girmez —
  /// seri nosuz bir kimlik birden fazla kutuyla yanlışlıkla eşleşebilir.
  static Object? _identityOf(String raw) {
    final code = Gs1DataMatrix.parse(raw.trim());
    final serial = code.serial;
    if (!code.hasGtin || serial == null || serial.isEmpty) return null;
    return code.identity;
  }

  /// Servisin `qrCode` alanını ayrı kodlara böler. Bölme yalnızca "(" ile
  /// başlayan bir AI'dan önceki virgülde yapılır — GS1 seri numarası virgül
  /// içerebilir, düz `split(',')` onu ikiye bölerdi.
  static List<String> parseList(String? raw) {
    if (raw == null) return const [];
    return raw.split(RegExp(r',(?=\s*\()')).map((c) => c.trim()).where((c) => c.isNotEmpty).toList(growable: false);
  }
}

/// İade başlamadan önce bir kalem için okutulması gereken karekodlar.
class RefundQrRequirement {
  const RefundQrRequirement({
    required this.itemId,
    required this.medicineName,
    required this.requiredCount,
    required this.matcher,
    this.expectedGtin,
  });

  /// RefundableItem.id (reçete detay id'si).
  final int itemId;
  final String medicineName;

  /// İade edilen kutu sayısı (Drug.boxCountOf — alımla aynı dönüşüm).
  final int requiredCount;

  final String? expectedGtin;
  final RefundQrCodeMatcher matcher;

  /// Alımda okutulan kutudan fazlası iade edilmek isteniyor — doğru kodlarla
  /// bile tamamlanamaz, dialog hiç açılmamalı.
  bool get isSatisfiable => requiredCount <= matcher.availableCount;
}
