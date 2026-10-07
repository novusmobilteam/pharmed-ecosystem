// [SWTEST-PRN-001..008] Termal yazıcı katmanı — cihaz gerektirmeyen testler.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmed_client/core/hardware/printer/printer.dart';
import 'package:pharmed_core/pharmed_core.dart';

PrinterFailureReason? _reasonOf<T>(Result<T> r) =>
    r.when(ok: (_) => null, error: (e) => e is PrinterException ? e.reason : null);

/// Gönderilen baytları kaydeden, istenirse hata fırlatan / bekleyen transport.
class _FakeTransport implements IPrinterTransport {
  _FakeTransport({this.error, this.delay = Duration.zero});

  final PrinterException? error;
  final Duration delay;
  final sent = <Uint8List>[];
  int active = 0;
  int maxConcurrent = 0;

  @override
  Future<void> send(Uint8List data, {required String jobName}) async {
    active++;
    if (active > maxConcurrent) maxConcurrent = active;
    try {
      await Future<void>.delayed(delay);
      if (error != null) throw error!;
      sent.add(data);
    } finally {
      active--;
    }
  }
}

const _serialConfig = PrinterConfig(connectionType: PrinterConnectionType.serial, target: 'COM5', baudRate: 115200);

const _sampleDoc = ReceiptDocument(
  title: 'Test',
  blocks: [
    ReceiptText('PharMed', size: ReceiptTextSize.title, align: ReceiptAlign.center),
    ReceiptKeyValue('Servis:', 'Göğüs Hastalıkları'),
    ReceiptDivider(ReceiptDividerStyle.dashed),
    ReceiptBarcode('869951200101', type: ReceiptBarcodeType.ean13),
    ReceiptText('İŞLEM YAPAN: Ayşe Yılmaz'),
  ],
);

bool _containsSequence(List<int> haystack, List<int> needle) {
  outer:
  for (var i = 0; i <= haystack.length - needle.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EAN-13 kontrol hanesi [SWTEST-PRN-001]', () {
    test('12 haneye kontrol hanesi eklenir', () {
      expect(EscPosEncoder.normalizeEan13('869951200101'), '8699512001012');
      expect(EscPosEncoder.normalizeEan13('869951200505'), '8699512005058');
    });

    test('doğru 13 hane kabul, yanlış kontrol hanesi ret', () {
      expect(EscPosEncoder.normalizeEan13('8699512001012'), '8699512001012');
      expect(EscPosEncoder.normalizeEan13('8699512001019'), isNull);
    });

    test('rakam dışı veya yanlış uzunluk ret', () {
      expect(EscPosEncoder.normalizeEan13('86995120010A'), isNull);
      expect(EscPosEncoder.normalizeEan13('12345'), isNull);
    });
  });

  group('Barkod kodlama [SWTEST-PRN-002]', () {
    const encoder = EscPosEncoder();

    test('geçerli EAN-13 yerel EAN-13 olarak kodlanır', () {
      final b = encoder.encodeBarcode('869951200101', ReceiptBarcodeType.ean13)!;
      expect(b.symbology, 67);
      expect(String.fromCharCodes(b.payload), '8699512001012');
    });

    test('geçersiz EAN-13 Code128 olarak basılır', () {
      final b = encoder.encodeBarcode('ABC-123', ReceiptBarcodeType.ean13)!;
      expect(b.symbology, 73);
      expect(String.fromCharCodes(b.payload), '{BABC-123');
    });

    test('çift uzunluklu sayısal veri Code128-C ile sıkıştırılır', () {
      final b = encoder.encodeBarcode('20261006', ReceiptBarcodeType.code128)!;
      expect(b.payload, [0x7B, 0x43, 20, 26, 10, 6]);
      expect(b.moduleWidth, 2);
    });

    test('uzun veri ince çubukla sığdırılır, hiç sığmayan null döner', () {
      expect(encoder.encodeBarcode('P' * 20, ReceiptBarcodeType.code128)!.moduleWidth, 1);
      expect(encoder.encodeBarcode('P' * 40, ReceiptBarcodeType.code128), isNull);
    });

    test('ASCII dışı karakter içeren veri kodlanmaz', () {
      expect(encoder.encodeBarcode('ÇĞŞ', ReceiptBarcodeType.code128), isNull);
    });
  });

  group('Raster bantlama [SWTEST-PRN-003]', () {
    test('uzun görüntü 255 satırlık bantlara bölünür', () {
      const encoder = EscPosEncoder();
      final bitmap = MonoBitmap(widthBytes: 48, height: 600, bits: Uint8List(48 * 600));
      final bytes = encoder.raster(bitmap);
      // 3 bant: 255 + 255 + 90, her biri 8 bayt başlık + veri.
      expect(bytes.length, 3 * 8 + 48 * 600);
      expect(bytes.sublist(0, 8), [0x1D, 0x76, 0x30, 0x00, 48, 0, 255, 0]);
      final lastHeader = 2 * (8 + 48 * 255);
      expect(bytes.sublist(lastHeader, lastHeader + 8), [0x1D, 0x76, 0x30, 0x00, 48, 0, 90, 0]);
    });
  });

  group('Rasterizer [SWTEST-PRN-004]', () {
    test('metin görüntüye, barkod yerel parçaya ayrılır', () async {
      final parts = await const ReceiptRasterizer().render(_sampleDoc);
      expect(parts.map((p) => p.runtimeType).toList(), [RasterPart, BarcodePart, RasterPart]);
      final first = (parts.first as RasterPart).bitmap;
      expect(first.widthBytes, 48);
      expect(first.bits.any((b) => b != 0), isTrue, reason: 'metin siyah piksel üretmeli');
    });

    test('kodlanamayan barkod metin olarak çizilir', () async {
      final parts = await const ReceiptRasterizer().render(
        const ReceiptDocument(title: 'x', blocks: [ReceiptBarcode('ÇĞŞ')]),
      );
      expect(parts.single, isA<RasterPart>());
    });
  });

  group('EscPosReceiptPrinter [SWTEST-PRN-005]', () {
    test('ayar yoksa notConfigured döner, gönderim yapılmaz', () async {
      final transport = _FakeTransport();
      final printer = EscPosReceiptPrinter(loadConfig: () async => null, transportFactory: (_) => transport);
      expect(_reasonOf(await printer.printReceipt(_sampleDoc)), PrinterFailureReason.notConfigured);
      expect(transport.sent, isEmpty);
    });

    test('boş fiş invalidDocument döner', () async {
      final printer = EscPosReceiptPrinter(
        loadConfig: () async => _serialConfig,
        transportFactory: (_) => _FakeTransport(),
      );
      final r = await printer.printReceipt(const ReceiptDocument(title: 'x', blocks: []));
      expect(_reasonOf(r), PrinterFailureReason.invalidDocument);
    });

    test('başarılı iş: ESC @ ile başlar, barkod komutu içerir, beyaz alan + LF ile biter', () async {
      final transport = _FakeTransport();
      final printer = EscPosReceiptPrinter(loadConfig: () async => _serialConfig, transportFactory: (_) => transport);
      final r = await printer.printReceipt(_sampleDoc);
      expect(r.isSuccess, isTrue);
      final bytes = transport.sent.single;
      expect(bytes.sublist(0, 2), [0x1B, 0x40]);
      expect(bytes.sublist(bytes.length - 4), [0x0A, 0x0A, 0x0A, 0x0A]);
      // Fiş sonu beyaz raster alanı: 320 nokta = 255 + 65 satırlık iki bant, tamamı sıfır.
      final tailStart = bytes.length - 4 - (2 * 8 + 48 * 320);
      expect(bytes.sublist(tailStart, tailStart + 8), [0x1D, 0x76, 0x30, 0x00, 48, 0, 255, 0]);
      expect(bytes.sublist(tailStart + 8, tailStart + 8 + 48 * 255).every((b) => b == 0), isTrue);
      expect(_containsSequence(bytes, [0x1D, 0x6B, 67, 13]), isTrue, reason: 'EAN-13 komutu');
      expect(_containsSequence(bytes, [0x1D, 0x76, 0x30, 0x00]), isTrue, reason: 'raster komutu');
    });
  });

  group('Hata yönetimi [SWTEST-PRN-006]', () {
    test('transport hatası exception değil Result.error olarak döner', () async {
      final printer = EscPosReceiptPrinter(
        loadConfig: () async => _serialConfig,
        transportFactory: (_) => _FakeTransport(
          error: const PrinterException(message: 'port yok', reason: PrinterFailureReason.connectionFailed),
        ),
      );
      expect(_reasonOf(await printer.printReceipt(_sampleDoc)), PrinterFailureReason.connectionFailed);
    });

    test('ayar okuma hatası unexpected olarak döner', () async {
      final printer = EscPosReceiptPrinter(
        loadConfig: () async => throw StateError('hive kapalı'),
        transportFactory: (_) => _FakeTransport(),
      );
      expect(_reasonOf(await printer.printReceipt(_sampleDoc)), PrinterFailureReason.unexpected);
    });
  });

  group('Kuyruk [SWTEST-PRN-007]', () {
    test('aynı anda gelen işler sırayla basılır', () async {
      final transport = _FakeTransport(delay: const Duration(milliseconds: 20));
      final printer = EscPosReceiptPrinter(loadConfig: () async => _serialConfig, transportFactory: (_) => transport);
      final results = await Future.wait([
        printer.printReceipt(_sampleDoc),
        printer.printReceipt(_sampleDoc),
        printer.printReceipt(_sampleDoc),
      ]);
      expect(results.every((r) => r.isSuccess), isTrue);
      expect(transport.sent, hasLength(3));
      expect(transport.maxConcurrent, 1);
    });

    test('hatalı iş kuyruğu kilitlemez', () async {
      var calls = 0;
      final printer = EscPosReceiptPrinter(
        loadConfig: () async => _serialConfig,
        transportFactory: (_) => calls++ == 0
            ? _FakeTransport(error: const PrinterException(message: 'x', reason: PrinterFailureReason.writeFailed))
            : _FakeTransport(),
      );
      expect((await printer.printReceipt(_sampleDoc)).isError, isTrue);
      expect((await printer.printReceipt(_sampleDoc)).isSuccess, isTrue);
    });
  });

  group('Gönderim zaman aşımı [SWTEST-PRN-008]', () {
    test('seri hatta veri boyutu ve baud ile ölçeklenir', () {
      // 115200 baud, 35 KB → ~3 sn beklenen → 2×3 + 30 = ~36 sn
      final fast = EscPosReceiptPrinter.sendTimeout(_serialConfig, 35000);
      expect(fast.inSeconds, inInclusiveRange(35, 37));
      // 9600 baud, 200 KB → ~208 sn beklenen → ~446 sn
      final slow = EscPosReceiptPrinter.sendTimeout(_serialConfig.copyWith(baudRate: 9600), 200000);
      expect(slow.inSeconds, greaterThan(400));
    });

    test('Windows kuyruğunda sabit 60 sn', () {
      const spooler = PrinterConfig(connectionType: PrinterConnectionType.windowsSpooler, target: 'POS-58');
      expect(EscPosReceiptPrinter.sendTimeout(spooler, 1 << 20), const Duration(seconds: 60));
    });
  });
}
