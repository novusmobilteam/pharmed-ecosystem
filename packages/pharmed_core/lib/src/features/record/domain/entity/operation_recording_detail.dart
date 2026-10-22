// [SWREQ-CORE-CAM-002] [IEC 62304 §5.5]
// Sunucudan okunan bir kabin operasyonu kaydı — izleme ekranları için.
// Sınıf: Class B

import 'package:equatable/equatable.dart';
import 'package:pharmed_core/pharmed_core.dart';

/// Bir kameranın videosunun sunucudaki durumu.
enum RecordedVideoStatus {
  /// Yüklendi ve doğrulandı — oynatılabilir.
  available,

  /// Video bekleniyor ama yükleme henüz tamamlanmadı (istasyon yüklüyor).
  pending,

  /// Saklama süresi dolduğu için sunucudan silindi.
  purged,

  /// Bu kamera için video yok (kamera kayda başlayamadı / video gönderilmedi).
  unavailable,
}

class RecordedCamera extends Equatable {
  const RecordedCamera({
    required this.cameraId,
    required this.cameraName,
    required this.status,
    this.failure,
    this.videoStartedAt,
    this.videoEndedAt,
    this.sizeBytes,
  });

  final String cameraId;
  final String cameraName;
  final RecordedVideoStatus status;

  /// Kamera kayda başlayamadıysa nedeni.
  final CameraRecordingFailureReason? failure;
  final DateTime? videoStartedAt;
  final DateTime? videoEndedAt;
  final int? sizeBytes;

  bool get isPlayable => status == RecordedVideoStatus.available;

  Duration? get duration {
    final start = videoStartedAt, end = videoEndedAt;
    return start == null || end == null ? null : end.difference(start);
  }

  @override
  List<Object?> get props => [cameraId, cameraName, status, failure, videoStartedAt, videoEndedAt, sizeBytes];
}

class RecordedMarker extends Equatable {
  const RecordedMarker({required this.type, required this.at, this.cabinDrawerId, this.cameraId, this.offsets = const {}});

  /// Bilinmeyen (yeni sürümde eklenmiş) tür null'dır.
  final RecordingMarkerType? type;
  final DateTime at;
  final int? cabinDrawerId;

  /// Yalnızca kameraya özgü olaylarda (recordingInterrupted).
  final String? cameraId;

  /// cameraId → videodaki konum.
  final Map<String, Duration> offsets;

  Duration? offsetFor(String cameraId) => offsets[cameraId];

  @override
  List<Object?> get props => [type, at, cabinDrawerId, cameraId, offsets];
}

class OperationRecordingDetail extends Equatable {
  const OperationRecordingDetail({
    required this.operationIds,
    required this.cabinIds,
    required this.cameras,
    required this.markers,
    this.type,
    this.startedAt,
    this.endedAt,
    this.endReason,
    this.operatorUserId,
  });

  /// Kaydın bağlı olduğu sunucu işlemleri.
  final List<int> operationIds;
  final RecordedOperationType? type;
  final List<int> cabinIds;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final OperationEndReason? endReason;
  final int? operatorUserId;
  final List<RecordedCamera> cameras;

  /// Zamana göre sıralı.
  final List<RecordedMarker> markers;

  bool get hasPlayableVideo => cameras.any((c) => c.isPlayable);

  @override
  List<Object?> get props => [
    operationIds,
    type,
    cabinIds,
    startedAt,
    endedAt,
    endReason,
    operatorUserId,
    cameras,
    markers,
  ];
}

/// Dio dışı bir istemcinin (video oynatıcı) videoyu çekebilmesi için adres
/// ve kimlik header'ları.
class RecordingVideoSource extends Equatable {
  const RecordingVideoSource({required this.uri, this.headers = const {}});

  final Uri uri;
  final Map<String, String> headers;

  @override
  List<Object?> get props => [uri, headers];
}
