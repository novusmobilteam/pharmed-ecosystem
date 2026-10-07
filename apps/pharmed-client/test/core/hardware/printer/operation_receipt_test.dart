// [SWTEST-PRN-090, 092, 093] İşlem fişi (alım / iade / fire / imha) — cihaz gerektirmeyen testler.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmed_client/core/hardware/printer/printer.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

Hospitalization _hosp(int id, String name, String surname, {String? protocol}) => Hospitalization(
  id: id,
  patient: Patient(id: id, name: name, surname: surname, protocolNo: protocol),
  room: Room(name: '31$id'),
  bed: Bed(name: '$id'),
);

OperationReceiptLine _line(String name, {Hospitalization? h, String? barcode}) =>
    OperationReceiptLine(medicineName: name, quantityLabel: '2 Adet', hospitalization: h, barcode: barcode);

List<String> _texts(ReceiptDocument d) => [
  for (final b in d.blocks)
    if (b is ReceiptText) b.text,
];

class _RecordingPrinter implements IReceiptPrinter {
  final printed = <ReceiptDocument>[];
  Result<void> result = const Result.ok(null);

  @override
  Future<Result<void>> printReceipt(ReceiptDocument document) async {
    printed.add(document);
    return result;
  }

  @override
  Future<void> close() async {}
}

void main() {
  setUp(() => setCurrentLocale(const Locale('tr')));

  group('Fiş içeriği [SWTEST-PRN-090]', () {
    test('kalemler hastaya göre gruplanır, her hastanın protokol barkodu basılır', () {
      final ayse = _hosp(1, 'Ayşe', 'Yılmaz', protocol: 'P2026100601');
      final mehmet = _hosp(2, 'Mehmet', 'Demir', protocol: 'P2026100602');
      final doc = buildOperationReceipt(
        kind: OperationReceiptKind.refund,
        lines: [_line('A', h: ayse), _line('B', h: mehmet), _line('C', h: ayse)],
        operatorName: 'Hem. Zeynep Kaya',
      );
      final texts = _texts(doc);
      expect(texts.where((t) => t == 'Ayşe Yılmaz'), hasLength(1));
      expect(texts.where((t) => t == 'Mehmet Demir'), hasLength(1));
      // Ayşe'nin iki kalemi aynı grupta ardışık numaralanır.
      expect(texts.indexOf('2. C'), lessThan(texts.indexOf('3. B')));
      final barcodes = doc.blocks.whereType<ReceiptBarcode>().map((b) => b.data).toList();
      expect(barcodes, containsAll(['P2026100601', 'P2026100602']));
    });

    test('hasta bağlamı olmayan kalemde hasta bloğu basılmaz', () {
      final doc = buildOperationReceipt(
        kind: OperationReceiptKind.destruction,
        lines: [_line('A')],
        operatorName: null,
      );
      expect(doc.blocks.whereType<ReceiptBarcode>(), isEmpty);
      expect(_texts(doc), contains('1. A'));
    });

    test('ilaç barkodu EAN-13 olarak istenir (geçersizse yazıcı Code128 basar)', () {
      final doc = buildOperationReceipt(
        kind: OperationReceiptKind.intake,
        lines: [_line('A', barcode: '8699512001012')],
        operatorName: 'x',
      );
      final b = doc.blocks.whereType<ReceiptBarcode>().single;
      expect(b.type, ReceiptBarcodeType.ean13);
    });
  });


  group('OperationReceiptService [SWTEST-PRN-092]', () {
    test('kalem yoksa yazdırma yapılmaz', () async {
      final printer = _RecordingPrinter();
      final service = OperationReceiptService(printer: printer, operatorName: () => 'x');
      final r = await service.printOperation(kind: OperationReceiptKind.intake, lines: const []);
      expect(r.isSuccess, isTrue);
      expect(printer.printed, isEmpty);
    });

    test('işlemi yapan kullanıcı yazdırma anında okunur', () async {
      final printer = _RecordingPrinter();
      var user = 'İlk';
      final service = OperationReceiptService(printer: printer, operatorName: () => user);
      user = 'Son';
      await service.printOperation(kind: OperationReceiptKind.intake, lines: [_line('A')]);
      final kv = printer.printed.single.blocks.whereType<ReceiptKeyValue>().map((b) => b.value);
      expect(kv, contains('Son'));
    });
  });

  group('Yazıcı hatası [SWTEST-PRN-093]', () {
    test('tanımlı yazıcının hatası Result.error olarak döner, exception fırlatılmaz', () async {
      final printer = _RecordingPrinter()
        ..result = const Result.error(
          PrinterException(message: 'port yok', reason: PrinterFailureReason.connectionFailed),
        );
      final service = OperationReceiptService(printer: printer, operatorName: () => 'x');
      final r = await service.printOperation(kind: OperationReceiptKind.refund, lines: [_line('A')]);
      expect(r.when(ok: (_) => null, error: printerFailureReasonOf), PrinterFailureReason.connectionFailed);
    });

    test('yazıcı tanımlı değilse fiş sessizce atlanır (yazıcısız kiosk)', () async {
      final printer = _RecordingPrinter()
        ..result = const Result.error(
          PrinterException(message: 'yok', reason: PrinterFailureReason.notConfigured),
        );
      final service = OperationReceiptService(printer: printer, operatorName: () => 'x');
      final r = await service.printOperation(kind: OperationReceiptKind.intake, lines: [_line('A')]);
      expect(r.isSuccess, isTrue);
    });
  });
}
