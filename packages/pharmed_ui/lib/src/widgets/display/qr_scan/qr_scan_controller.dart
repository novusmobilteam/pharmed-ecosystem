// [SWREQ-UI-QRSCAN-001] [IEC 62304 §5.5]
// Karekod okutma dialog'unun (QrScanDialog) yerel tarama durumu: okutulan kodlar, doğrulama
// (GS1 çözümleme, GTIN eşleşmesi, tekrar tespiti) ve reddedilen son okuma.
// Dialog ömrüyle sınırlı — gönderim çağıranın onSubmit callback'inde.
//
// Sınıf: Class B

import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum QrScanRejection {
  /// Geçerli bir GTIN çözümlenemedi — karekod değil ya da okuma bozuk.
  unreadable('KK-OKUNAMADI'),

  /// GTIN, alınan ilacın GTIN'i ile eşleşmiyor — yanlış ilaç.
  gtinMismatch('KK-GTIN-UYUMSUZ'),

  /// Aynı kutu (GTIN + seri no) bu dialog'da zaten okutuldu.
  duplicate('KK-SERI-TEKRAR');

  const QrScanRejection(this.errorCode);

  /// Kullanıcıya gösterilen, çevrilmeyen hata kodu (destek/iz sürme için).
  final String errorCode;
}

class QrScanError {
  const QrScanError({required this.rejection, required this.code, this.duplicateOfIndex});

  final QrScanRejection rejection;
  final Gs1Code code;

  /// [QrScanRejection.duplicate] için listedeki ilk okumanın sırası (0 tabanlı).
  final int? duplicateOfIndex;
}

class QrScanController extends ChangeNotifier {
  QrScanController({required this.requiredCount, String? expectedGtin})
    : expectedGtin = Gs1DataMatrix.normalizeGtin(expectedGtin);

  /// Okutulması gereken kutu sayısı.
  final int requiredCount;

  /// İlacın 14 haneye tamamlanmış GTIN'i. null ise eşleşme kontrolü yapılmaz.
  final String? expectedGtin;

  final List<Gs1Code> _codes = [];
  List<Gs1Code> get codes => List.unmodifiable(_codes);

  QrScanError? _error;
  QrScanError? get error => _error;

  bool get isMulti => requiredCount > 1;
  int get scannedCount => _codes.length;
  bool get isComplete => _codes.length >= requiredCount;

  /// Sıradaki kutunun 1 tabanlı sırası.
  int get nextBoxNumber => _codes.length + 1;

  /// Backend'e gönderilecek ham değerler — okuyucudan geldiği haliyle.
  List<String> get rawCodes => [for (final c in _codes) c.raw];

  /// Okuyucudan (veya elle) gelen bir değeri değerlendirir. Kabul edilirse
  /// listeye eklenir ve varsa önceki hata temizlenir; reddedilirse [error]
  /// set edilir, liste değişmez.
  void submit(String input) {
    final text = input.trim();
    if (text.isEmpty) return;

    if (isComplete) {
      // Tüm kutular okutulduktan sonra gelen okuma — sessizce yok sayılır;
      // kullanıcı bir kodu kaldırıp yeniden okutabilir.
      MedLogger.info(
        unit: 'QrScan',
        swreq: 'SWREQ-UI-QRSCAN-001',
        message: 'Tüm kutular okutulmuşken gelen okuma yok sayıldı',
      );
      return;
    }

    final code = Gs1DataMatrix.parse(text);

    if (!code.hasGtin) {
      _reject(QrScanRejection.unreadable, code);
      return;
    }
    if (expectedGtin != null && code.gtin != expectedGtin) {
      _reject(QrScanRejection.gtinMismatch, code);
      return;
    }
    final duplicateIndex = _codes.indexWhere((c) => c.identity == code.identity);
    if (duplicateIndex >= 0) {
      _reject(QrScanRejection.duplicate, code, duplicateOfIndex: duplicateIndex);
      return;
    }

    if (code.isHeuristic) {
      MedLogger.info(
        unit: 'QrScan',
        swreq: 'SWREQ-UI-QRSCAN-001',
        message: 'Karekod GS ayırıcısı olmadan çözümlendi (tahmini alan sınırı)',
        context: {'gtin': code.gtin, 'serial': code.serial},
      );
    }

    _codes.add(code);
    _error = null;
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= _codes.length) return;
    _codes.removeAt(index);
    _error = null;
    notifyListeners();
  }

  /// Tekli alımda "Yeniden Okut": okutulan kodu ve hatayı temizler.
  void reset() {
    _codes.clear();
    _error = null;
    notifyListeners();
  }

  void dismissError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void _reject(QrScanRejection rejection, Gs1Code code, {int? duplicateOfIndex}) {
    MedLogger.warn(
      unit: 'QrScan',
      swreq: 'SWREQ-UI-QRSCAN-001',
      message: 'Karekod reddedildi',
      context: {
        'reason': rejection.errorCode,
        'scannedGtin': code.gtin,
        'rawGtin': code.rawGtin,
        'invalidCheckDigit': code.hasInvalidCheckDigit,
        'expectedGtin': expectedGtin,
        'serial': code.serial,
      },
    );
    _error = QrScanError(rejection: rejection, code: code, duplicateOfIndex: duplicateOfIndex);
    notifyListeners();
  }
}
