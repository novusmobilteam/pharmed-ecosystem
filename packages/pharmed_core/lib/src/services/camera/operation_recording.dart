import 'package:equatable/equatable.dart';
import 'package:pharmed_core/pharmed_core.dart';

import 'recording_file.dart';

/// Kaydı alınan kabin operasyonunun türü.
enum RecordedOperationType { refill, census, intake, refund, waste, unload }

/// Operasyonun nasıl sona erdiği (videonun değil, operasyonun).
enum OperationEndReason {
  /// Kuyruk sonuna kadar işlendi (aradaki başarısız çekmeceler işaretlerde görünür).
  completed,

  /// Kullanıcı "Dur" ile kuyruğu bitirdi.
  stoppedByUser,

  /// Kuyruk hatası sonrası kullanıcı işlemi sonlandırdı.
  abortedAfterError,

  /// Operasyon sürerken ekran kapandı / notifier dispose edildi.
  screenClosed,

  /// Önceki operasyon kapatılmadan yeni operasyon başladı. Beklenmeyen durum;
  /// bir çıkış noktasında end() çağrısının unutulduğunu gösterir.
  superseded,

  /// Uygulama kayıt sürerken kapandı/çöktü; kayıt açılışta staging
  /// alanından kurtarıldı. İşaretler ve kesin bitiş zamanı yoktur.
  recovered,
}

enum RecordingMarkerType {
  drawerOpened,
  drawerClosed,
  drawerFailed,

  /// Kübik: gözün kapağı açıldı / kapandı / açılamadı.
  lidOpened,
  lidClosed,
  lidFailed,

  /// Bir kameranın akışı operasyon bitmeden koptu ([RecordingMarker.cameraId]).
  recordingInterrupted,
}

/// Operasyon sırasında olan bir olay. Videoda ilgili ana atlamak için kullanılır.
class RecordingMarker extends Equatable {
  const RecordingMarker({required this.type, required this.at, this.cabinDrawerId, this.cameraId});

  final RecordingMarkerType type;

  /// Mutlak zaman. Bir videodaki konum için [CameraTrack.offsetOf].
  final DateTime at;

  /// Çekmece olaylarında fiziksel çekmece (DrawerSlot.id).
  final int? cabinDrawerId;

  /// Yalnızca kameraya özgü olaylarda (recordingInterrupted).
  final String? cameraId;

  @override
  List<Object?> get props => [type, at, cabinDrawerId, cameraId];
}

/// Operasyona katılan bir kameranın sonucu: videosu ya da neden alınamadığı.
class CameraTrack extends Equatable {
  const CameraTrack({required this.cameraId, required this.cameraName, this.video, this.failure});

  final String cameraId;
  final String cameraName;

  /// Kamera başlatılamadıysa veya stop başarısızsa null.
  final RecordingFile? video;

  /// Kamera başlatılamadıysa nedeni.
  final CameraRecordingFailureReason? failure;

  bool get hasVideo => video != null;

  /// İşaretin bu videodaki konumu. Video yoksa veya olay video başlamadan
  /// önceyse null.
  Duration? offsetOf(RecordingMarker marker) {
    final v = video;
    if (v == null) return null;
    final offset = marker.at.difference(v.startedAt);
    return offset.isNegative ? null : offset;
  }

  CameraTrack withVideo(RecordingFile? video) =>
      CameraTrack(cameraId: cameraId, cameraName: cameraName, video: video, failure: failure);

  @override
  List<Object?> get props => [cameraId, cameraName, video, failure];
}

/// Operasyon başında diske yazılan ön bilgi (write-ahead). Uygulama kayıt
/// sırasında çökerse, açılışta kayıt bu bilgiyle kurtarılır. [SWREQ-CAM-021]
class OperationRecordingStart extends Equatable {
  const OperationRecordingStart({
    required this.operationId,
    required this.type,
    required this.cabinIds,
    required this.startedAt,
    required this.cameras,
    this.userId,
    this.userFullName,
  });

  final String operationId;
  final RecordedOperationType type;
  final Set<int> cabinIds;
  final DateTime startedAt;

  /// Kayda katılan kameralar: id → ad.
  final Map<String, String> cameras;
  final int? userId;
  final String? userFullName;

  @override
  List<Object?> get props => [operationId, type, cabinIds, startedAt, cameras, userId, userFullName];
}

/// Bir kabin operasyonunun kayıt özeti — outbox'a giden birim.
///
/// Kamera olmasa da üretilir: "bu operasyon kamerasız yapıldı" bilgisi de
/// denetim açısından anlamlıdır.
class OperationRecording extends Equatable {
  const OperationRecording({
    required this.operationId,
    required this.type,
    required this.cabinIds,
    required this.startedAt,
    required this.endedAt,
    required this.endReason,
    required this.markers,
    required this.tracks,
    this.userId,
    this.userFullName,
  });

  final String operationId;
  final RecordedOperationType type;

  /// Operasyonun dokunduğu kabinler (dolum listesi gibi işlemler birden
  /// fazla kabine yayılabilir).
  final Set<int> cabinIds;
  final DateTime startedAt;
  final DateTime endedAt;
  final OperationEndReason endReason;
  final List<RecordingMarker> markers;

  /// Kayda katılan her kamera için bir iz. Boşsa operasyonun kabinlerine
  /// atanmış kamera yoktu.
  final List<CameraTrack> tracks;

  /// İşlemi yapan kullanıcı. Sunucuya gönderilirken asıl kaynak JWT'dir;
  /// bu alan lokal arşivde filtreleme/inceleme içindir.
  final int? userId;
  final String? userFullName;

  bool get hasVideo => tracks.any((t) => t.hasVideo);

  OperationRecording withTracks(List<CameraTrack> tracks) => OperationRecording(
    operationId: operationId,
    type: type,
    cabinIds: cabinIds,
    startedAt: startedAt,
    endedAt: endedAt,
    endReason: endReason,
    markers: markers,
    tracks: tracks,
    userId: userId,
    userFullName: userFullName,
  );

  @override
  List<Object?> get props => [
    operationId,
    type,
    cabinIds,
    startedAt,
    endedAt,
    endReason,
    markers,
    tracks,
    userId,
    userFullName,
  ];
}
