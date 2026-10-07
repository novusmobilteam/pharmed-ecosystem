// pharmed_core/lib/src/services/printer/i_receipt_printer.dart
//
// [SWREQ-PRN-002] [IEC 62304 §5.5]
// Termal fiş yazıcısı soyutlaması.
//
// Kurallar:
//   - printReceipt() hiçbir koşulda exception fırlatmaz; her hata
//     Result.error(PrinterException) olarak döner.
//   - Yazdırma, stok işleminin bir parçası DEĞİLDİR. Çağıran taraf fişi
//     işlem kaydı başarıyla tamamlandıktan sonra basar ve yazdırma
//     hatasında kaydı geri almaz.
//   - Aynı anda gelen işler sırayla basılır; fişler birbirine karışmaz.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IReceiptPrinter {
  /// Fişi yazıcıya gönderir. Gönderim tamamlandığında (veya hata oluştuğunda) döner.
  Future<Result<void>> printReceipt(ReceiptDocument document);

  /// Açık kaynakları serbest bırakır.
  Future<void> close();
}
