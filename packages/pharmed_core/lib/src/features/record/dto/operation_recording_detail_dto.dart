import 'package:pharmed_core/pharmed_core.dart';

/// GET /OperationRecording/{operationId} yanıtı: yüklenen metadata ve
/// sunucudaki video durumları. [SWREQ-DATA-CAM-002]
class OperationRecordingDetailDTO {
  const OperationRecordingDetailDTO({this.metadata, this.videos});

  final OperationRecordingMetadataDTO? metadata;
  final List<RecordingVideoStatusDTO>? videos;

  factory OperationRecordingDetailDTO.fromJson(Map<String, dynamic> json) => OperationRecordingDetailDTO(
    metadata: json['metadata'] is Map
        ? OperationRecordingMetadataDTO.fromJson((json['metadata'] as Map).cast<String, dynamic>())
        : null,
    videos: (json['videos'] as List?)
        ?.map((e) => RecordingVideoStatusDTO.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
  );
}

/// Sunucudaki bir kamera videosunun durumu.
class RecordingVideoStatusDTO {
  const RecordingVideoStatusDTO({this.cameraId, this.completedAt, this.purgedAt, this.sizeBytes, this.sha256});

  final String? cameraId;

  /// Parçalar birleştirilip hash doğrulandığı an. null → yükleme tamamlanmadı.
  final String? completedAt;

  /// Saklama süresi dolup video silindiyse silinme anı.
  final String? purgedAt;
  final int? sizeBytes;
  final String? sha256;

  factory RecordingVideoStatusDTO.fromJson(Map<String, dynamic> json) => RecordingVideoStatusDTO(
    cameraId: json['cameraId'] as String?,
    completedAt: json['completedAt'] as String?,
    purgedAt: json['purgedAt'] as String?,
    sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
    sha256: json['sha256'] as String?,
  );
}
