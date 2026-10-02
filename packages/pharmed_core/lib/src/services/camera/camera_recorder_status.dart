import 'recording_file.dart';

/// Kaydedicinin anlık durumu.
///
/// Geçişler:
/// Idle → Starting → Recording → Stopping → Idle
///                       ↓
///                  Interrupted → (stop) → Stopping → Idle
/// Starting başarısız olursa doğrudan Idle'a döner.
sealed class CameraRecorderStatus {
  const CameraRecorderStatus();
}

final class RecorderIdle extends CameraRecorderStatus {
  const RecorderIdle();
}

final class RecorderStarting extends CameraRecorderStatus {
  const RecorderStarting(this.sessionId);
  final String sessionId;
}

final class RecorderRecording extends CameraRecorderStatus {
  const RecorderRecording({required this.sessionId, required this.startedAt});
  final String sessionId;
  final DateTime startedAt;
}

/// Kayıt `stop()` çağrılmadan kendiliğinden bitti. [SWREQ-CAM-004]
/// Dosya yine de `stop()` ile teslim alınmalıdır; o ana kadarki görüntü geçerlidir.
final class RecorderInterrupted extends CameraRecorderStatus {
  const RecorderInterrupted({required this.sessionId, required this.reason});
  final String sessionId;
  final RecordingEndReason reason;
}

final class RecorderStopping extends CameraRecorderStatus {
  const RecorderStopping(this.sessionId);
  final String sessionId;
}
