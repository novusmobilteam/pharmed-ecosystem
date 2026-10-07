// pharmed-client/lib/core/hardware/fingerprint/mock_fingerprint_scanner.dart
//
// Mock flavor ve okuyucusuz geliştirme için IFingerprintScanner.
// Gerçek DLL yüklemez. [captureDelay] sonra sabit bir "parmak" okur;
// [nextFailure] ile bir sonraki okumanın hatası test senaryolarında seçilebilir.
//
// Döndürülen şablon gerçek bir ISO 19794-2 şablonu DEĞİLDİR; yalnızca akışı
// sürmek içindir. [fingerSeed] değiştirilerek "farklı kullanıcı" taklit edilir.

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pharmed_core/pharmed_core.dart';

class MockFingerprintScanner implements IFingerprintScanner {
  MockFingerprintScanner({this.captureDelay = const Duration(seconds: 2), this.quality = 82, this.fingerSeed = 1});

  final Duration captureDelay;

  /// Okumanın döndüreceği kalite. minQuality testleri için değiştirilebilir.
  int quality;

  /// Aynı seed → aynı şablon (aynı parmak).
  int fingerSeed;

  /// Bir sonraki capture() bu nedenle başarısız olur, sonra sıfırlanır.
  FingerprintFailureReason? nextFailure;

  bool _open = false;
  Completer<Result<FingerprintCapture>>? _pending;
  Timer? _timer;

  @override
  bool get isOpen => _open;

  @override
  Future<Result<FingerprintScannerInfo>> open() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _open = true;
    return const Result.ok(
      FingerprintScannerInfo(
        vendor: 'mock',
        model: 'Mock okuyucu',
        scannerType: 0,
        livenessActive: true,
        serial: 'MOCK-0001',
        sdkVersion: 'mock',
      ),
    );
  }

  @override
  Future<Result<FingerprintCapture>> capture({
    Duration timeout = const Duration(seconds: 10),
    int minQuality = 30,
    bool includeImage = false,
  }) {
    if (!_open) return Future.value(_error<FingerprintCapture>(FingerprintFailureReason.notOpen));
    if (_pending != null) return Future.value(_error<FingerprintCapture>(FingerprintFailureReason.busy));

    final completer = Completer<Result<FingerprintCapture>>();
    _pending = completer;

    final failure = nextFailure;
    nextFailure = null;
    final wait = failure == FingerprintFailureReason.timeout ? timeout : captureDelay;

    _timer = Timer(wait, () {
      if (failure != null) {
        _finish(_error(failure));
      } else if (quality < minQuality) {
        _finish(_error(FingerprintFailureReason.lowQuality));
      } else {
        _finish(
          Result.ok(
            FingerprintCapture(
              template: _template(fingerSeed),
              format: FingerprintTemplateFormat.iso19794_2,
              quality: quality,
              lfdScore: 95,
              capturedAt: DateTime.now(),
              image: includeImage ? _image(fingerSeed) : null,
            ),
          ),
        );
      }
    });
    return completer.future;
  }

  @override
  Future<void> cancelCapture() async {
    if (_pending == null) return;
    _finish(_error(FingerprintFailureReason.cancelled));
  }

  @override
  Future<Result<bool>> isFingerOn() async {
    if (!_open) return _error(FingerprintFailureReason.notOpen);
    if (_pending != null) return _error(FingerprintFailureReason.busy);
    return const Result.ok(false);
  }

  @override
  Future<void> close() async {
    await cancelCapture();
    _open = false;
  }

  void _finish(Result<FingerprintCapture> result) {
    _timer?.cancel();
    _timer = null;
    final pending = _pending;
    _pending = null;
    pending?.complete(result);
  }

  static Result<T> _error<T>(FingerprintFailureReason reason) =>
      Result.error(FingerprintException(message: 'Mock parmak izi hatası: ${reason.name}', reason: reason));

  static Uint8List _template(int seed) {
    final rnd = math.Random(seed);
    return Uint8List.fromList([
      0x46, 0x4D, 0x52, 0x00, // "FMR\0" — ISO 19794-2 başlığına benzer, gerçek değil
      ...List.generate(508, (_) => rnd.nextInt(256)),
    ]);
  }

  /// Test ekranında görüntü akışını denemek için eşmerkezli halkalar.
  static FingerprintImage _image(int seed) {
    const w = 300, h = 400;
    final pixels = Uint8List(w * h);
    final cx = w / 2, cy = h / 2 + seed % 20;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final dx = (x - cx) / 1.0, dy = (y - cy) / 1.3;
        final r = math.sqrt(dx * dx + dy * dy);
        final inside = r < 140;
        pixels[y * w + x] = inside && (r ~/ 6).isEven ? 40 : 230;
      }
    }
    return FingerprintImage(width: w, height: h, resolutionDpi: 500, pixels: pixels);
  }
}
