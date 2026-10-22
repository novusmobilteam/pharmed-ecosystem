import 'package:pharmed_core/pharmed_core.dart';

class OperationRecordingDetailMapper {
  const OperationRecordingDetailMapper();

  /// Metadata yoksa (beklenmeyen yanıt) null.
  OperationRecordingDetail? toEntity(OperationRecordingDetailDTO dto) {
    final m = dto.metadata;
    if (m == null) return null;

    final videos = {for (final v in dto.videos ?? const <RecordingVideoStatusDTO>[]) v.cameraId: v};

    final markers = [
      for (final mk in m.markers ?? const <RecordingMarkerDTO>[])
        if (_date(mk.at) case final at?)
          RecordedMarker(
            type: _enum(RecordingMarkerType.values, mk.type),
            at: at,
            cabinDrawerId: mk.cabinDrawerId,
            cameraId: mk.cameraId,
            offsets: {for (final e in (mk.videoOffsetsMs ?? const {}).entries) e.key: Duration(milliseconds: e.value)},
          ),
    ]..sort((a, b) => a.at.compareTo(b.at));

    return OperationRecordingDetail(
      operationIds: [...?m.operationIds],
      type: _enum(RecordedOperationType.values, m.operationType),
      cabinIds: [...?m.cabinIds],
      startedAt: _date(m.startedAt),
      endedAt: _date(m.endedAt),
      endReason: _enum(OperationEndReason.values, m.endReason),
      operatorUserId: m.operatorUserId,
      markers: markers,
      cameras: [
        for (final c in m.cameras ?? const <RecordingCameraDTO>[])
          if (c.cameraId case final id?)
            RecordedCamera(
              cameraId: id,
              cameraName: c.cameraName ?? id,
              status: _status(c, videos[id]),
              failure: _enum(CameraRecordingFailureReason.values, c.failure),
              videoStartedAt: _date(c.videoStartedAt),
              videoEndedAt: _date(c.videoEndedAt),
              sizeBytes: videos[id]?.sizeBytes ?? c.sizeBytes,
            ),
      ],
    );
  }

  static RecordedVideoStatus _status(RecordingCameraDTO camera, RecordingVideoStatusDTO? video) {
    if (video?.purgedAt != null) return RecordedVideoStatus.purged;
    if (video?.completedAt != null) return RecordedVideoStatus.available;
    if (camera.videoExpected ?? false) return RecordedVideoStatus.pending;
    return RecordedVideoStatus.unavailable;
  }

  static DateTime? _date(String? s) => s == null ? null : DateTime.tryParse(s)?.toLocal();

  static T? _enum<T extends Enum>(List<T> values, String? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}
