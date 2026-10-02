/// Sunucuya giden operasyon kaydı metadata'sı.
/// Kullanıcı kimliği GÖNDERİLMEZ — sunucu JWT'den alır.
class OperationRecordingMetadataDTO {
  const OperationRecordingMetadataDTO({
    this.operationId,
    this.operationType,
    this.cabinIds,
    this.startedAt,
    this.endedAt,
    this.endReason,
    this.cameras,
    this.markers,
  });

  final String? operationId;
  final String? operationType;
  final List<int>? cabinIds;
  final String? startedAt;
  final String? endedAt;
  final String? endReason;
  final List<RecordingCameraDTO>? cameras;
  final List<RecordingMarkerDTO>? markers;

  factory OperationRecordingMetadataDTO.fromJson(Map<String, dynamic> json) => OperationRecordingMetadataDTO(
    operationId: json['operationId'] as String?,
    operationType: json['operationType'] as String?,
    cabinIds: (json['cabinIds'] as List?)?.cast<int>(),
    startedAt: json['startedAt'] as String?,
    endedAt: json['endedAt'] as String?,
    endReason: json['endReason'] as String?,
    cameras: (json['cameras'] as List?)
        ?.map((e) => RecordingCameraDTO.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
    markers: (json['markers'] as List?)
        ?.map((e) => RecordingMarkerDTO.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'operationId': operationId,
    'operationType': operationType,
    'cabinIds': cabinIds,
    'startedAt': startedAt,
    'endedAt': endedAt,
    'endReason': endReason,
    'cameras': cameras?.map((e) => e.toJson()).toList(),
    'markers': markers?.map((e) => e.toJson()).toList(),
  };
}

class RecordingCameraDTO {
  const RecordingCameraDTO({
    this.cameraId,
    this.cameraName,
    this.videoExpected,
    this.failure,
    this.sizeBytes,
    this.sha256,
    this.videoStartedAt,
    this.videoEndedAt,
    this.videoEndReason,
    this.contentType,
  });

  final String? cameraId;
  final String? cameraName;

  /// Sunucu bu kamera için video parçası bekleyecek mi?
  final bool? videoExpected;

  /// Kamera kayda giremediyse nedeni.
  final String? failure;

  final int? sizeBytes;
  final String? sha256;
  final String? videoStartedAt;
  final String? videoEndedAt;
  final String? videoEndReason;
  final String? contentType;

  factory RecordingCameraDTO.fromJson(Map<String, dynamic> json) => RecordingCameraDTO(
    cameraId: json['cameraId'] as String?,
    cameraName: json['cameraName'] as String?,
    videoExpected: json['videoExpected'] as bool?,
    failure: json['failure'] as String?,
    sizeBytes: json['sizeBytes'] as int?,
    sha256: json['sha256'] as String?,
    videoStartedAt: json['videoStartedAt'] as String?,
    videoEndedAt: json['videoEndedAt'] as String?,
    videoEndReason: json['videoEndReason'] as String?,
    contentType: json['contentType'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'cameraId': cameraId,
    'cameraName': cameraName,
    'videoExpected': videoExpected,
    'failure': failure,
    'sizeBytes': sizeBytes,
    'sha256': sha256,
    'videoStartedAt': videoStartedAt,
    'videoEndedAt': videoEndedAt,
    'videoEndReason': videoEndReason,
    'contentType': contentType,
  };
}

class RecordingMarkerDTO {
  const RecordingMarkerDTO({this.type, this.at, this.cabinDrawerId, this.cameraId, this.videoOffsetsMs});

  final String? type;
  final String? at;
  final int? cabinDrawerId;
  final String? cameraId;

  /// cameraId → o videodaki konum (ms).
  final Map<String, int>? videoOffsetsMs;

  factory RecordingMarkerDTO.fromJson(Map<String, dynamic> json) => RecordingMarkerDTO(
    type: json['type'] as String?,
    at: json['at'] as String?,
    cabinDrawerId: json['cabinDrawerId'] as int?,
    cameraId: json['cameraId'] as String?,
    videoOffsetsMs: (json['videoOffsetsMs'] as Map?)?.cast<String, int>(),
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'at': at,
    'cabinDrawerId': cabinDrawerId,
    'cameraId': cameraId,
    'videoOffsetsMs': videoOffsetsMs,
  };
}
