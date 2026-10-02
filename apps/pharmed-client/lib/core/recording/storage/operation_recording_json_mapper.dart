import 'package:path/path.dart' as p;
import 'package:pharmed_core/pharmed_core.dart';

/// Lokal arşivdeki `.json` dosyalarının (sidecar ve staging manifest) formatı.
///
/// - Zamanlar UTC ISO-8601 yazılır.
/// - Enum'lar adlarıyla yazılır; bilinmeyen değer güvenli varsayılana düşer.
/// - Video dosyaları sidecar'a göre GÖRELİ adla yazılır (arşiv taşınabilir).
/// - `schemaVersion` format değişirse geriye dönük okumayı mümkün kılar.
class OperationRecordingJsonMapper {
  const OperationRecordingJsonMapper();

  static const schemaVersion = 2; // v2: çoklu kamera (tracks)

  // ── Sidecar ───────────────────────────────────────────────────────────────

  Map<String, Object?> toJson(OperationRecording r) => {
    'schemaVersion': schemaVersion,
    'operationId': r.operationId,
    'type': r.type.name,
    'cabinIds': r.cabinIds.toList()..sort(),
    'userId': r.userId,
    'userFullName': r.userFullName,
    'startedAt': _ts(r.startedAt),
    'endedAt': _ts(r.endedAt),
    'endReason': r.endReason.name,
    'tracks': [
      for (final t in r.tracks)
        {
          'cameraId': t.cameraId,
          'cameraName': t.cameraName,
          'failure': t.failure?.name,
          'video': switch (t.video) {
            null => null,
            final v => {
              'fileName': p.basename(v.path),
              'startedAt': _ts(v.startedAt),
              'endedAt': _ts(v.endedAt),
              'sizeBytes': v.sizeBytes,
              'sha256': v.sha256,
              'endReason': v.endReason.name,
              'contentType': 'video/mp4',
            },
          },
        },
    ],
    'markers': [
      for (final m in r.markers)
        {
          'type': m.type.name,
          'at': _ts(m.at),
          'cabinDrawerId': m.cabinDrawerId,
          'cameraId': m.cameraId,
          // Her videodaki konum — izleyicinin doğrudan atlayabilmesi için.
          'videoOffsetsMs': {
            for (final t in r.tracks)
              if (t.offsetOf(m) case final o?) t.cameraId: o.inMilliseconds,
          },
        },
    ],
  };

  /// [sidecarDir]: video dosyalarının çözüleceği klasör. Diskte olmayan video
  /// null okunur (ör. disk baskısıyla tahliye edilmiş).
  OperationRecording fromJson(
    Map<String, Object?> json, {
    required String sidecarDir,
    bool Function(String path)? exists,
  }) {
    final operationId = json['operationId']! as String;
    final fileExists = exists ?? (_) => true;
    return OperationRecording(
      operationId: operationId,
      type: _enum(RecordedOperationType.values, json['type'], RecordedOperationType.refill),
      cabinIds: _cabinIds(json),
      userId: json['userId'] as int?,
      userFullName: json['userFullName'] as String?,
      startedAt: DateTime.parse(json['startedAt']! as String),
      endedAt: DateTime.parse(json['endedAt']! as String),
      endReason: _enum(OperationEndReason.values, json['endReason'], OperationEndReason.recovered),
      tracks: [
        for (final t in (json['tracks'] as List<Object?>? ?? const []).cast<Map<String, Object?>>())
          CameraTrack(
            cameraId: t['cameraId']! as String,
            cameraName: (t['cameraName'] as String?) ?? '',
            failure: t['failure'] == null
                ? null
                : _enum(CameraRecordingFailureReason.values, t['failure'], CameraRecordingFailureReason.unexpected),
            video: _video(t['video'] as Map<String, Object?>?, operationId, sidecarDir, fileExists),
          ),
      ],
      markers: [
        for (final m in (json['markers'] as List<Object?>? ?? const []).cast<Map<String, Object?>>())
          RecordingMarker(
            type: _enum(RecordingMarkerType.values, m['type'], RecordingMarkerType.recordingInterrupted),
            at: DateTime.parse(m['at']! as String),
            cabinDrawerId: m['cabinDrawerId'] as int?,
            cameraId: m['cameraId'] as String?,
          ),
      ],
    );
  }

  RecordingFile? _video(Map<String, Object?>? v, String opId, String dir, bool Function(String) exists) {
    if (v == null) return null;
    final path = p.join(dir, v['fileName']! as String);
    if (!exists(path)) return null;
    return RecordingFile(
      sessionId: opId,
      path: path,
      startedAt: DateTime.parse(v['startedAt']! as String),
      endedAt: DateTime.parse(v['endedAt']! as String),
      sizeBytes: v['sizeBytes']! as int,
      sha256: v['sha256']! as String,
      endReason: _enum(RecordingEndReason.values, v['endReason'], RecordingEndReason.forceKilled),
    );
  }

  // ── Staging manifest (write-ahead) ────────────────────────────────────────

  Map<String, Object?> startToJson(OperationRecordingStart s) => {
    'schemaVersion': schemaVersion,
    'operationId': s.operationId,
    'type': s.type.name,
    'cabinIds': s.cabinIds.toList()..sort(),
    'cameras': s.cameras,
    'userId': s.userId,
    'userFullName': s.userFullName,
    'startedAt': _ts(s.startedAt),
  };

  OperationRecordingStart startFromJson(Map<String, Object?> json) => OperationRecordingStart(
    operationId: json['operationId']! as String,
    type: _enum(RecordedOperationType.values, json['type'], RecordedOperationType.refill),
    cabinIds: _cabinIds(json),
    cameras: (json['cameras'] as Map<String, Object?>? ?? const {}).cast<String, String>(),
    userId: json['userId'] as int?,
    userFullName: json['userFullName'] as String?,
    startedAt: DateTime.parse(json['startedAt']! as String),
  );

  static Set<int> _cabinIds(Map<String, Object?> json) {
    final list = json['cabinIds'] as List<Object?>?;
    if (list != null) return list.cast<int>().toSet();
    final single = json['cabinId'] as int?; // schemaVersion 1
    return single == null ? <int>{} : {single};
  }

  static String _ts(DateTime d) => d.toUtc().toIso8601String();

  static T _enum<T extends Enum>(List<T> values, Object? name, T fallback) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }
}
