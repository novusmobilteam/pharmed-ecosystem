// pharmed-client/lib/core/hardware/printer/esc_pos_receipt_printer.dart
//
// [SWREQ-PRN-040] [IEC 62304 §5.5]
// IReceiptPrinter — EM5820 (58 mm, ESC/POS) uygulaması.
//
// Akış (her iş için):
//   1. Ayar okunur (her işte yeniden — ayar ekranındaki değişiklik anında geçerli)
//   2. Fiş görüntüye çevrilir (ReceiptRasterizer)
//   3. ESC/POS baytları üretilir (EscPosEncoder)
//   4. Bağlantı türüne göre transport ile gönderilir
//
// Güvenlik:
//   - Hiçbir hata dışarı exception olarak çıkmaz → Result.error(PrinterException)
//   - İşler tek kuyrukta sırayla basılır; aynı anda gelen iki fiş karışmaz
//   - Her iş MedLogger ile loglanır (başlık, blok sayısı, bayt, süre, sonuç)
//
// Sınıf: Class B

import 'dart:async';
import 'dart:typed_data';

// pharmed_core'un TimeoutException'ı (AppException) dart:async'inkiyle çakışır.
import 'package:pharmed_core/pharmed_core.dart' hide TimeoutException;
import 'package:pharmed_ui/pharmed_ui.dart';

import 'esc_pos_encoder.dart';
import 'printer_transport.dart';
import 'receipt_rasterizer.dart';

typedef PrinterConfigLoader = Future<PrinterConfig?> Function();
typedef PrinterTransportFactory = IPrinterTransport Function(PrinterConfig config);

class EscPosReceiptPrinter implements IReceiptPrinter {
  EscPosReceiptPrinter({
    required PrinterConfigLoader loadConfig,
    ReceiptRasterizer rasterizer = const ReceiptRasterizer(),
    PrinterTransportFactory? transportFactory,
    this.tailBlankDots = 320,
    this.tailFeedLines = 4,
    this.renderTimeout = const Duration(seconds: 30),
  }) : _loadConfig = loadConfig,
       _rasterizer = rasterizer,
       _transportFactory = transportFactory ?? defaultTransport;

  static const _unit = 'SW-UNIT-PRN';

  final PrinterConfigLoader _loadConfig;
  final ReceiptRasterizer _rasterizer;
  final PrinterTransportFactory _transportFactory;

  /// Fiş sonu boşluğu — son satırın yazıcı kafasından yırtma kenarını geçmesi için.
  ///
  /// EM5820 `ESC d n` (n satır ilerlet) komutunu güvenilir uygulamadığından
  /// boşluk, yazıcının kesin bastığı beyaz bir raster alanla verilir
  /// (8 nokta ≈ 1 mm; 320 nokta ≈ 40 mm). Ardından [tailFeedLines] kadar LF.
  final int tailBlankDots;
  final int tailFeedLines;

  /// Fişin görüntüye çevrilmesi için üst sınır.
  final Duration renderTimeout;

  EscPosEncoder get _encoder => _rasterizer.encoder;

  /// İşleri sıraya dizen zincir; her yeni iş öncekinin bitmesini bekler.
  Future<void> _queue = Future.value();

  static IPrinterTransport defaultTransport(PrinterConfig config) => switch (config.connectionType) {
    PrinterConnectionType.serial => SerialPrinterTransport(portName: config.target, baudRate: config.baudRate),
    PrinterConnectionType.windowsSpooler => WindowsSpoolerPrinterTransport(printerName: config.target),
  };

  @override
  Future<Result<void>> printReceipt(ReceiptDocument document) {
    final completer = Completer<Result<void>>();
    _queue = _queue.then((_) async {
      completer.complete(await _runJob(document));
    });
    return completer.future;
  }

  Future<Result<void>> _runJob(ReceiptDocument document) async {
    final stopwatch = Stopwatch()..start();
    PrinterConfig? config;
    var byteCount = 0;

    try {
      if (document.isEmpty) {
        throw const PrinterException(message: 'Boş fiş yazdırılamaz', reason: PrinterFailureReason.invalidDocument);
      }

      config = await _loadConfig();
      if (config == null || !config.isValid) {
        throw const PrinterException(
          message: 'Yazıcı bağlantısı tanımlanmamış',
          reason: PrinterFailureReason.notConfigured,
        );
      }

      final bytes = await encode(document).timeout(renderTimeout);
      byteCount = bytes.length;

      await _transportFactory(config)
          .send(bytes, jobName: 'PharMed - ${document.title}')
          .timeout(
            sendTimeout(config, byteCount),
            onTimeout: () => throw const PrinterException(
              message: 'Yazdırma zaman aşımına uğradı',
              reason: PrinterFailureReason.timeout,
            ),
          );

      MedLogger.info(
        unit: _unit,
        swreq: 'SWREQ-PRN-040',
        message: 'Fiş yazdırıldı',
        context: _context(document, config, byteCount, stopwatch),
      );
      return const Result.ok(null);
    } on PrinterException catch (e, st) {
      _logFailure(e, st, document, config, byteCount, stopwatch);
      return Result.error(e);
    } on TimeoutException catch (e, st) {
      final error = PrinterException(
        message: 'Fiş hazırlama zaman aşımına uğradı',
        reason: PrinterFailureReason.timeout,
        cause: e,
      );
      _logFailure(error, st, document, config, byteCount, stopwatch);
      return Result.error(error);
    } catch (e, st) {
      final error = PrinterException(
        message: 'Beklenmeyen yazdırma hatası',
        reason: PrinterFailureReason.unexpected,
        cause: e,
      );
      _logFailure(error, st, document, config, byteCount, stopwatch);
      return Result.error(error);
    }
  }

  /// Gönderim üst sınırı: seri hatta veri boyutu ve baud'a göre (beklenen sürenin
  /// 2 katı + 30 sn), kuyrukta sabit 60 sn. Uzun envanter listesi 9600 baud'da
  /// dakikalar sürebileceğinden sabit bir süre kullanılmaz.
  static Duration sendTimeout(PrinterConfig config, int byteCount) {
    if (config.connectionType != PrinterConnectionType.serial) return const Duration(seconds: 60);
    final expectedMs = byteCount * 10 * 1000 ~/ config.baudRate;
    return Duration(milliseconds: expectedMs * 2 + 30000);
  }

  /// Fişi yazıcıya gidecek ESC/POS baytlarına çevirir.
  Future<Uint8List> encode(ReceiptDocument document) async {
    final List<RenderedPart> parts;
    try {
      parts = await _rasterizer.render(document);
    } on PrinterException {
      rethrow;
    } catch (e) {
      throw PrinterException(message: 'Fiş görüntüye çevrilemedi', reason: PrinterFailureReason.renderFailed, cause: e);
    }

    final out = BytesBuilder(copy: false)..add(_encoder.initialize());
    for (final part in parts) {
      switch (part) {
        case RasterPart(:final bitmap):
          out.add(_encoder.raster(bitmap));
        case BarcodePart(:final barcode, :final height):
          out.add(_encoder.barcode(barcode, height: height));
      }
    }
    if (tailBlankDots > 0) {
      final widthBytes = _encoder.paperWidthDots ~/ 8;
      out.add(
        _encoder.raster(
          MonoBitmap(widthBytes: widthBytes, height: tailBlankDots, bits: Uint8List(widthBytes * tailBlankDots)),
        ),
      );
    }
    out.add(List<int>.filled(tailFeedLines, 0x0A));
    return out.toBytes();
  }

  Map<String, dynamic> _context(
    ReceiptDocument document,
    PrinterConfig? config,
    int byteCount,
    Stopwatch stopwatch,
  ) => {
    'title': document.title,
    'blocks': document.blocks.length,
    'bytes': byteCount,
    'connection': config?.connectionType.name,
    'target': config?.target,
    'baud': config?.connectionType == PrinterConnectionType.serial ? config?.baudRate : null,
    'elapsedMs': stopwatch.elapsedMilliseconds,
  };

  void _logFailure(
    PrinterException error,
    StackTrace stackTrace,
    ReceiptDocument document,
    PrinterConfig? config,
    int byteCount,
    Stopwatch stopwatch,
  ) {
    // Tanımsız yazıcı arıza değil, kiosk yapılandırmasıdır.
    if (error.reason == PrinterFailureReason.notConfigured) {
      MedLogger.warn(
        unit: _unit,
        swreq: 'SWREQ-PRN-040',
        message: 'Fiş yazdırılmadı: yazıcı tanımlı değil',
        context: _context(document, config, byteCount, stopwatch),
      );
      return;
    }
    MedLogger.error(
      unit: _unit,
      swreq: 'SWREQ-PRN-040',
      message: 'Fiş yazdırılamadı: ${error.message}',
      context: {..._context(document, config, byteCount, stopwatch), 'reason': error.reason.name},
      error: error.cause ?? error,
      stackTrace: stackTrace,
    );
  }

  @override
  Future<void> close() async {
    // Port her iş için açılıp kapatıldığından tutulan kaynak yok; bekleyen işler biter.
    await _queue;
  }
}
