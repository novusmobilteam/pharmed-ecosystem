// [SWTEST-FP-001..009] Parmak izi okuyucu katmanı — cihaz gerektirmeyen testler.

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmed_client/core/hardware/fingerprint/biomini/biomini_bindings.dart';
import 'package:pharmed_client/core/hardware/fingerprint/biomini/biomini_worker.dart';
import 'package:pharmed_client/core/hardware/fingerprint/fingerprint.dart';
import 'package:pharmed_client/core/hardware/fingerprint/secugen/secugen_bindings.dart';
import 'package:pharmed_client/core/hardware/fingerprint/secugen/secugen_worker.dart';
import 'package:pharmed_core/pharmed_core.dart';

FingerprintFailureReason? _reasonOf<T>(Result<T> r) =>
    r.when(ok: (_) => null, error: (e) => e is FingerprintException ? e.reason : null);

/// Her zaman verilen nedenle açılamayan okuyucu (otomatik seçim testleri için).
class _FailingScanner implements IFingerprintScanner {
  _FailingScanner(this.reason);
  final FingerprintFailureReason reason;
  int openCalls = 0;
  int closeCalls = 0;

  @override
  bool get isOpen => false;

  @override
  Future<Result<FingerprintScannerInfo>> open() async {
    openCalls++;
    return Result.error(FingerprintException(message: 'test', reason: reason));
  }

  @override
  Future<void> close() async {
    closeCalls++;
  }

  @override
  Future<Result<FingerprintCapture>> capture({
    Duration timeout = const Duration(seconds: 10),
    int minQuality = 30,
    bool includeImage = false,
  }) async => Result.error(FingerprintException(message: 'test', reason: reason));

  @override
  Future<void> cancelCapture() async {}

  @override
  Future<Result<bool>> isFingerOn() async => Result.error(FingerprintException(message: 'test', reason: reason));
}

void main() {
  group('BioMiniFingerprintScanner.reasonOf [SWTEST-FP-001]', () {
    const cases = <int, FingerprintFailureReason>{
      BioMiniLocalStatus.libraryLoadFailed: FingerprintFailureReason.libraryNotFound,
      BioMiniLocalStatus.noScanner: FingerprintFailureReason.deviceNotFound,
      Ufs.errNoLicense: FingerprintFailureReason.deviceNotFound,
      Ufs.errDeviceNotRespond: FingerprintFailureReason.deviceDisconnected,
      Ufs.errUsbTimeout: FingerprintFailureReason.deviceDisconnected,
      Ufs.errCaptureTimeout: FingerprintFailureReason.timeout,
      Ufs.errTimeout: FingerprintFailureReason.timeout,
      Ufs.errFakeFinger: FingerprintFailureReason.fakeFinger,
      Ufs.errFingerOnSensor: FingerprintFailureReason.fingerOnSensor,
      Ufs.errNotGoodImage: FingerprintFailureReason.lowQuality,
      Ufs.errSensorDirty: FingerprintFailureReason.sensorDirty,
      Ufs.errExtractionFailed: FingerprintFailureReason.extractionFailed,
      -351: FingerprintFailureReason.extractionFailed,
      -359: FingerprintFailureReason.extractionFailed,
      -401: FingerprintFailureReason.extractionFailed,
      -405: FingerprintFailureReason.extractionFailed,
      Ufs.errCaptureRunning: FingerprintFailureReason.busy,
      Ufs.error: FingerprintFailureReason.unexpected,
      -350: FingerprintFailureReason.unexpected,
      -406: FingerprintFailureReason.unexpected,
    };
    for (final MapEntry(key: status, value: reason) in cases.entries) {
      test('$status → ${reason.name}', () => expect(BioMiniFingerprintScanner.reasonOf(status), reason));
    }
  });

  group('BioMiniFingerprintScanner (okuyucu yokken) [SWTEST-FP-002]', () {
    test('open() olmadan capture() notOpen döner', () async {
      final scanner = BioMiniFingerprintScanner(dllPath: 'olmayan.dll');
      expect(_reasonOf(await scanner.capture()), FingerprintFailureReason.notOpen);
      expect(scanner.isOpen, isFalse);
    });
  });

  group('MockFingerprintScanner [SWTEST-FP-003..006]', () {
    late MockFingerprintScanner scanner;

    setUp(() async {
      scanner = MockFingerprintScanner(captureDelay: const Duration(milliseconds: 20));
      await scanner.open();
    });
    tearDown(() => scanner.close());

    test('aynı parmak aynı şablonu, farklı parmak farklı şablonu verir', () async {
      final a = (await scanner.capture()).data!;
      final b = (await scanner.capture()).data!;
      scanner.fingerSeed = 2;
      final c = (await scanner.capture()).data!;
      expect(a.template, b.template);
      expect(a.template, isNot(c.template));
      expect(a.format, FingerprintTemplateFormat.iso19794_2);
    });

    test('eşzamanlı ikinci capture busy döner, iptal cancelled döner', () async {
      final first = scanner.capture(timeout: const Duration(seconds: 5));
      expect(_reasonOf(await scanner.capture()), FingerprintFailureReason.busy);
      await scanner.cancelCapture();
      expect(_reasonOf(await first), FingerprintFailureReason.cancelled);
    });

    test('kalite eşiğin altındaysa lowQuality döner', () async {
      scanner.quality = 25;
      expect(_reasonOf(await scanner.capture(minQuality: 30)), FingerprintFailureReason.lowQuality);
    });

    test('nextFailure bir kez uygulanır', () async {
      scanner.nextFailure = FingerprintFailureReason.fakeFinger;
      expect(_reasonOf(await scanner.capture()), FingerprintFailureReason.fakeFinger);
      expect((await scanner.capture()).isSuccess, isTrue);
    });

    test('includeImage görüntüyü doldurur, toString şablonu ifşa etmez', () async {
      final capture = (await scanner.capture(includeImage: true)).data!;
      final image = capture.image!;
      expect(image.pixels.length, image.width * image.height);
      expect(capture.toString(), isNot(contains('[')));
    });
  });

  group('SecuGenFingerprintScanner.reasonOf [SWTEST-FP-007]', () {
    const cases = <int, FingerprintFailureReason>{
      SecuGenLocalStatus.libraryLoadFailed: FingerprintFailureReason.libraryNotFound,
      Sg.errDllLoadFailedAlgo: FingerprintFailureReason.libraryNotFound,
      Sg.errDllLoadFailedWsq: FingerprintFailureReason.libraryNotFound,
      SecuGenLocalStatus.noScanner: FingerprintFailureReason.deviceNotFound,
      Sg.errDllLoadFailedDrv: FingerprintFailureReason.deviceNotFound,
      Sg.errDeviceNotFound: FingerprintFailureReason.deviceNotFound,
      Sg.errLineDropped: FingerprintFailureReason.deviceDisconnected,
      Sg.errDevAlreadyOpen: FingerprintFailureReason.busy,
      Sg.errTimeOut: FingerprintFailureReason.timeout,
      SecuGenLocalStatus.cancelled: FingerprintFailureReason.cancelled,
      Sg.errFakeFinger: FingerprintFailureReason.fakeFinger,
      Sg.errWrongImage: FingerprintFailureReason.extractionFailed,
      Sg.errFeatNumber: FingerprintFailureReason.extractionFailed,
      Sg.errFunctionFailed: FingerprintFailureReason.unexpected,
    };
    for (final MapEntry(key: status, value: reason) in cases.entries) {
      test('$status → ${reason.name}', () => expect(SecuGenFingerprintScanner.reasonOf(status), reason));
    }
    test('canlılık yalnızca U20 ailesinde', () {
      expect(secuGenSupportsLiveness(Sg.devFdu07), isFalse); // U10
      expect(secuGenSupportsLiveness(Sg.devFdu08a), isTrue); // U20-AP
    });
  });

  group('AutoFingerprintScanner [SWTEST-FP-008..009]', () {
    test('ilk açılamayan atlanır ve kapatılır, sonraki aktif olur', () async {
      final missing = _FailingScanner(FingerprintFailureReason.deviceNotFound);
      final mock = MockFingerprintScanner(captureDelay: const Duration(milliseconds: 10));
      final auto = AutoFingerprintScanner([missing, mock]);

      final opened = await auto.open();
      expect(opened.isSuccess, isTrue);
      expect(opened.data!.vendor, 'mock');
      expect(missing.closeCalls, 1);
      expect(identical(auto.active, mock), isTrue);
      expect((await auto.capture()).isSuccess, isTrue);
      await auto.close();
      expect(auto.isOpen, isFalse);
    });

    test('hiçbiri açılamazsa "cihaz yok" dışındaki hata öncelikli raporlanır', () async {
      final auto = AutoFingerprintScanner([
        _FailingScanner(FingerprintFailureReason.deviceNotFound),
        _FailingScanner(FingerprintFailureReason.busy),
      ]);
      expect(_reasonOf(await auto.open()), FingerprintFailureReason.busy);
      expect(_reasonOf(await auto.capture()), FingerprintFailureReason.notOpen);
    });
  });
}
