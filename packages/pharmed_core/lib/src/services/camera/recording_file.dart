import 'package:equatable/equatable.dart';

/// Bir operasyon kaydının neden sona erdiği.
enum RecordingEndReason {
  /// `stop()` ile temiz kapanış.
  stopped,

  /// `stop()` geldi ama ffmpeg süresinde kapanmadı; süreç öldürüldü.
  /// Fragmented MP4 sayesinde dosya oynatılabilir, son birkaç saniye eksik olabilir.
  forceKilled,

  /// `maxDuration` sınırına ulaşıldı; kayıt kendiliğinden durdu.
  maxDurationReached,

  /// Kamera/ağ akışı koptu; ffmpeg kendiliğinden çıktı.
  streamLost,
}

/// Tamamlanmış bir operasyon kaydı. [SWREQ-CAM-003]
class RecordingFile extends Equatable {
  const RecordingFile({
    required this.sessionId,
    required this.path,
    required this.startedAt,
    required this.endedAt,
    required this.sizeBytes,
    required this.sha256,
    required this.endReason,
  });

  final String sessionId;
  final String path;
  final DateTime startedAt;
  final DateTime endedAt;
  final int sizeBytes;

  /// Dosyanın SHA-256 özeti (hex). Servis tarafında bütünlük doğrulaması için.
  final String sha256;
  final RecordingEndReason endReason;

  Duration get duration => endedAt.difference(startedAt);

  RecordingFile copyWith({String? path}) => RecordingFile(
    sessionId: sessionId,
    path: path ?? this.path,
    startedAt: startedAt,
    endedAt: endedAt,
    sizeBytes: sizeBytes,
    sha256: sha256,
    endReason: endReason,
  );

  /// Kayıt kesintisiz ve temiz mi kapandı?
  bool get isComplete => endReason == RecordingEndReason.stopped;

  @override
  List<Object?> get props => [sessionId, path, startedAt, endedAt, sizeBytes, sha256, endReason];
}
