// pharmed-client/lib/core/hardware/fingerprint/auto_fingerprint_scanner.dart
//
// [SWREQ-FP-070]
// Birden fazla üreticiyi destekleyen IFingerprintScanner. Kioskta hangi okuyucu
// takılıysa onu kullanır; uygulamanın geri kalanı üreticiyi bilmez.
//
// open():
//   Adaylar sırayla denenir; ilk açılan "aktif" olur. Açılamayan aday kapatılır
//   (SDK'sı serbest bırakılır), böylece iki üreticinin SDK'sı aynı anda açık kalmaz.
//   Hiçbiri açılamazsa en anlamlı hata döner (bkz. [_pickFailure]).
// capture()/cancelCapture()/isFingerOn(): aktif okuyucuya iletilir.
// Aktif okuyucu bağlantı hatasıyla kapanırsa (isOpen=false) bir sonraki open()
// tüm adayları baştan dener — okuyucu değiştirilmiş olabilir.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class AutoFingerprintScanner implements IFingerprintScanner {
  AutoFingerprintScanner(this.candidates) : assert(candidates.isNotEmpty);

  static const _unit = 'SW-UNIT-FP';
  static const _swreq = 'SWREQ-FP-070';

  /// Deneme sırası önemlidir: önce gelen tercih edilir.
  final List<IFingerprintScanner> candidates;

  IFingerprintScanner? _active;
  Future<Result<FingerprintScannerInfo>>? _opening;

  /// Şu an kullanılan okuyucu (açık değilse null). Test ekranı ayar göstermek için kullanır.
  IFingerprintScanner? get active => _active?.isOpen == true ? _active : null;

  @override
  bool get isOpen => active != null;

  @override
  Future<Result<FingerprintScannerInfo>> open() => _opening ??= _open().whenComplete(() => _opening = null);

  Future<Result<FingerprintScannerInfo>> _open() async {
    final current = active;
    if (current != null) return current.open();
    _active = null;

    final failures = <AppException>[];
    for (final candidate in candidates) {
      final result = await candidate.open();
      if (result.isSuccess) {
        _active = candidate;
        final info = result.data!;
        MedLogger.info(
          unit: _unit,
          swreq: _swreq,
          message: 'Parmak izi okuyucu seçildi',
          context: {'vendor': info.vendor, 'model': info.model, 'triedBefore': failures.length},
        );
        return result;
      }
      result.when(ok: (_) {}, error: failures.add);
      await candidate.close(); // SDK'yı serbest bırak; diğer üreticiyle çakışmasın
    }

    final failure = _pickFailure(failures);
    MedLogger.warn(
      unit: _unit,
      swreq: _swreq,
      message: 'Hiçbir parmak izi okuyucu açılamadı',
      context: {
        'reasons': [for (final f in failures) f is FingerprintException ? f.reason.name : f.runtimeType.toString()],
      },
    );
    return Result.error(failure);
  }

  /// Hepsi "cihaz yok" ise o; değilse ilk farklı hata (DLL eksik, okuyucu meşgul vb.)
  /// daha bilgilendiricidir: takılı olan okuyucunun neden açılamadığını söyler.
  static AppException _pickFailure(List<AppException> failures) {
    for (final f in failures) {
      if (f is FingerprintException && f.reason != FingerprintFailureReason.deviceNotFound) {
        // Bir üreticinin DLL'i eksik ama okuyucusu da takılı değilse bu hata yanıltıcı olur;
        // yine de kurulum eksikliğini görünür kılmak için raporlanır.
        return f;
      }
    }
    return failures.isNotEmpty
        ? failures.first
        : const FingerprintException(
            message: 'Parmak izi okuyucu bulunamadı',
            reason: FingerprintFailureReason.deviceNotFound,
          );
  }

  @override
  Future<Result<FingerprintCapture>> capture({
    Duration timeout = const Duration(seconds: 10),
    int minQuality = 30,
    bool includeImage = false,
  }) {
    final scanner = active;
    if (scanner == null) return Future.value(_notOpen<FingerprintCapture>());
    return scanner.capture(timeout: timeout, minQuality: minQuality, includeImage: includeImage);
  }

  @override
  Future<void> cancelCapture() async => _active?.cancelCapture();

  @override
  Future<Result<bool>> isFingerOn() {
    final scanner = active;
    if (scanner == null) return Future.value(_notOpen<bool>());
    return scanner.isFingerOn();
  }

  @override
  Future<void> close() async {
    final scanner = _active;
    _active = null;
    await scanner?.close();
  }

  // Tip parametresi (T) const ifadede kullanılamaz; yalnızca exception const.
  static Result<T> _notOpen<T>() => Result.error(
    const FingerprintException(message: 'Okuyucu açık değil', reason: FingerprintFailureReason.notOpen),
  );
}
