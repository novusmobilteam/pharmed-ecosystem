import 'package:pharmed_core/pharmed_core.dart';

/// Kabin operasyonu süresince kamera kaydı alan bileşen.
///
/// Aynı anda yalnızca TEK aktif kayıt olabilir (kiosk başına tek kamera).
/// Uygulama tarafında global (autoDispose olmayan) provider olarak tutulur.
abstract interface class IOperationRecorder {
  CameraRecorderStatus get status;

  /// Durum değişimleri. Broadcast; son değeri tekrar yaymaz — anlık durum için [status].
  Stream<CameraRecorderStatus> get statusStream;

  /// Kaydı başlatır. Akış gerçekten dosyaya yazılmaya başladığında `ok` döner;
  /// yani `ok` geldiyse görüntü kaydediliyor demektir. [SWREQ-CAM-001] [SWREQ-CAM-002]
  Future<Result<void>> start({required String sessionId});

  /// Kaydı durdurur, dosyayı doğrular, SHA-256 hesaplar ve teslim eder.
  /// `RecorderRecording` veya `RecorderInterrupted` durumunda çağrılır. [SWREQ-CAM-003]
  Future<Result<RecordingFile>> stop();

  /// Kaydı iptal eder ve dosyayı SİLER. Operasyon hiç gerçekleşmeden
  /// vazgeçildiğinde kullanılır; denetim kaydı gereken durumlarda `stop()` tercih edilir.
  Future<void> abort();

  /// Aktif kayıt varsa temiz kapatmayı dener; dosyayı SİLMEZ.
  Future<void> dispose();
}
