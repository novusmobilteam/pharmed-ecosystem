import 'package:pharmed_core/pharmed_core.dart';

class OperationRecordingMetadataMapper {
  const OperationRecordingMetadataMapper();

  /// Zamanlar UTC ISO-8601; enum'lar adlarıyla.
  OperationRecordingMetadataDTO toDto(OperationRecording r, {required Set<String> videoCameraIds}) =>
      OperationRecordingMetadataDTO(
        operationId: r.operationId,
        operationType: r.type.name,
        cabinIds: r.cabinIds.toList()..sort(),
        startedAt: _ts(r.startedAt),
        endedAt: _ts(r.endedAt),
        endReason: r.endReason.name,
        cameras: [
          for (final t in r.tracks)
            RecordingCameraDTO(
              cameraId: t.cameraId,
              cameraName: t.cameraName,
              videoExpected: videoCameraIds.contains(t.cameraId),
              failure: t.failure?.name,
              sizeBytes: t.video?.sizeBytes,
              sha256: t.video?.sha256,
              videoStartedAt: t.video == null ? null : _ts(t.video!.startedAt),
              videoEndedAt: t.video == null ? null : _ts(t.video!.endedAt),
              videoEndReason: t.video?.endReason.name,
              contentType: t.video == null ? null : 'video/mp4',
            ),
        ],
        markers: [
          for (final m in r.markers)
            RecordingMarkerDTO(
              type: m.type.name,
              at: _ts(m.at),
              cabinDrawerId: m.cabinDrawerId,
              cameraId: m.cameraId,
              videoOffsetsMs: {
                for (final t in r.tracks)
                  if (t.offsetOf(m) case final o?) t.cameraId: o.inMilliseconds,
              },
            ),
        ],
      );

  Set<int> receivedChunksToEntity(List<int>? chunks) => {...?chunks};

  static String _ts(DateTime d) => d.toUtc().toIso8601String();
}
