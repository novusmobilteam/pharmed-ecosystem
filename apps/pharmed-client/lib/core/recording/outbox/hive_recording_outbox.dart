import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart'; // MedLogger

import 'package:pharmed_client/core/recording/storage/recording_storage.dart';

/// Upload yaşam döngüsü.
enum RecordingUploadState {
  /// Arşivlendi, sunucuya hiçbir şey gitmedi.
  pending,

  /// Metadata sunucuda; videolar yükleniyor/bekliyor.
  metadataSent,

  /// Sunucu kaydı ve tüm videolarını doğruladı. Lokal kopya artık yalnızca
  /// saklama süresi boyunca önbellektir.
  verified,

  /// Kalıcı hata (4xx, tekrarlayan hash uyuşmazlığı). Otomatik denenmez;
  /// inceleme gerektirir. Dosyalar korunur.
  rejected,
}

class OutboxVideo {
  const OutboxVideo({required this.cameraId, required this.path, required this.bytes});
  final String cameraId;
  final String path;
  final int bytes;

  Map<String, Object?> toJson() => {'cameraId': cameraId, 'path': path, 'bytes': bytes};

  factory OutboxVideo.fromJson(Map<String, Object?> j) =>
      OutboxVideo(cameraId: j['cameraId']! as String, path: j['path']! as String, bytes: j['bytes']! as int);
}

/// Outbox indeks kaydı. Hive'da küçük tutulur (işaretler vb. sidecar'da):
/// günde binlerce kayıtta bile indeks birkaç MB'ı geçmez.
class RecordingOutboxEntry {
  const RecordingOutboxEntry({
    required this.operationId,
    required this.type,
    required this.createdAt,
    required this.sidecarPath,
    required this.state,
    this.videos = const [],
    this.completedVideos = const {},
    this.videoEvicted = false,
    this.verifiedByStub = false,
    this.attempts = 0,
    this.hashMismatches = 0,
    this.nextAttemptAt,
    this.lastError,
  });

  final String operationId;
  final RecordedOperationType type;
  final DateTime createdAt;
  final String sidecarPath;
  final RecordingUploadState state;

  /// Operasyonun lokal videoları (kamera başına bir).
  final List<OutboxVideo> videos;

  /// Sunucunun doğruladığı videolar (cameraId). Kısmi ilerleme kaybolmaz.
  final Set<String> completedVideos;

  /// Disk baskısı nedeniyle videolar yüklenmeden silindi; sadece metadata gider.
  final bool videoEvicted;

  /// API henüz yokken sahte yanıtla "doğrulandı" (RecordingUploadApi.isAvailable
  /// = false). Veri hiçbir yere gitmedi: saklama kuralı bunu YÜKLENMEMİŞ sayar,
  /// API açılınca kayıt yeniden kuyruğa girer.
  final bool verifiedByStub;

  /// Sunucu gerçekten doğruladı mı? Saklama kuralları buna bakar.
  bool get isServerVerified => state == RecordingUploadState.verified && !verifiedByStub;

  final int attempts;
  final int hashMismatches;
  final DateTime? nextAttemptAt;
  final String? lastError;

  bool get hasVideoOnDisk => videos.isNotEmpty && !videoEvicted;

  int get videoBytes => hasVideoOnDisk ? videos.fold(0, (s, v) => s + v.bytes) : 0;

  List<OutboxVideo> get pendingVideos =>
      hasVideoOnDisk ? videos.where((v) => !completedVideos.contains(v.cameraId)).toList() : const [];

  /// Sunucunun video bekleyeceği kameralar. Tahliye sonrası yalnızca zaten
  /// yüklenmiş olanlar.
  Set<String> get expectedVideoCameraIds => videoEvicted ? completedVideos : videos.map((v) => v.cameraId).toSet();

  bool isDue(DateTime now) =>
      (state == RecordingUploadState.pending || state == RecordingUploadState.metadataSent) &&
      (nextAttemptAt == null || !nextAttemptAt!.isAfter(now));

  RecordingOutboxEntry copyWith({
    RecordingUploadState? state,
    Set<String>? completedVideos,
    bool? videoEvicted,
    bool? verifiedByStub,
    int? attempts,
    int? hashMismatches,
    DateTime? nextAttemptAt,
    bool clearNextAttempt = false,
    String? lastError,
    bool clearError = false,
  }) => RecordingOutboxEntry(
    operationId: operationId,
    type: type,
    createdAt: createdAt,
    sidecarPath: sidecarPath,
    state: state ?? this.state,
    videos: videos,
    completedVideos: completedVideos ?? this.completedVideos,
    videoEvicted: videoEvicted ?? this.videoEvicted,
    verifiedByStub: verifiedByStub ?? this.verifiedByStub,
    attempts: attempts ?? this.attempts,
    hashMismatches: hashMismatches ?? this.hashMismatches,
    nextAttemptAt: clearNextAttempt ? null : (nextAttemptAt ?? this.nextAttemptAt),
    lastError: clearError ? null : (lastError ?? this.lastError),
  );

  Map<String, Object?> toJson() => {
    'operationId': operationId,
    'type': type.name,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'sidecarPath': sidecarPath,
    'state': state.name,
    'videos': [for (final v in videos) v.toJson()],
    'completedVideos': completedVideos.toList(),
    'videoEvicted': videoEvicted,
    'verifiedByStub': verifiedByStub,
    'attempts': attempts,
    'hashMismatches': hashMismatches,
    'nextAttemptAt': nextAttemptAt?.toUtc().toIso8601String(),
    'lastError': lastError,
  };

  factory RecordingOutboxEntry.fromJson(Map<String, Object?> j) => RecordingOutboxEntry(
    operationId: j['operationId']! as String,
    type: RecordedOperationType.values.firstWhere(
      (v) => v.name == j['type'],
      orElse: () => RecordedOperationType.refill,
    ),
    createdAt: DateTime.parse(j['createdAt']! as String),
    sidecarPath: j['sidecarPath']! as String,
    state: RecordingUploadState.values.firstWhere(
      (v) => v.name == j['state'],
      orElse: () => RecordingUploadState.pending,
    ),
    videos: [
      for (final v in (j['videos'] as List<Object?>? ?? const []).cast<Map<String, Object?>>()) OutboxVideo.fromJson(v),
    ],
    completedVideos: (j['completedVideos'] as List<Object?>? ?? const []).cast<String>().toSet(),
    videoEvicted: (j['videoEvicted'] as bool?) ?? false,
    verifiedByStub: (j['verifiedByStub'] as bool?) ?? false,
    attempts: (j['attempts'] as int?) ?? 0,
    hashMismatches: (j['hashMismatches'] as int?) ?? 0,
    nextAttemptAt: j['nextAttemptAt'] == null ? null : DateTime.parse(j['nextAttemptAt']! as String),
    lastError: j['lastError'] as String?,
  );

  static RecordingOutboxEntry fromRecording(OperationRecording r, String sidecarPath) => RecordingOutboxEntry(
    operationId: r.operationId,
    type: r.type,
    createdAt: r.startedAt,
    sidecarPath: sidecarPath,
    state: RecordingUploadState.pending,
    videos: [
      for (final t in r.tracks)
        if (t.video case final v?) OutboxVideo(cameraId: t.cameraId, path: v.path, bytes: v.sizeBytes),
    ],
  );
}

/// Transactional outbox: kayıt önce dosya + indeks olarak kalıcılaşır, upload
/// worker'ı ayrı ve kendi hızında çalışır. [SWREQ-CAM-021] [SWREQ-CAM-022]
class HiveRecordingOutbox implements IOperationRecordingOutbox {
  HiveRecordingOutbox({required RecordingStorage storage, this.boxName = 'recording_outbox'}) : _storage = storage;

  static const _unit = 'SW-UNIT-CAM';

  final RecordingStorage _storage;
  final String boxName;

  Box<String>? _box;
  final _changes = StreamController<void>.broadcast();
  Future<void> _lock = Future<void>.value();

  /// Yeni kayıt girdi / bir kayıt güncellendi — worker dinler.
  Stream<void> get changes => _changes.stream;

  Future<Box<String>> _open() async => _box ??= await Hive.openBox<String>(boxName);

  // ── IOperationRecordingOutbox ─────────────────────────────────────────────

  @override
  Future<void> stage(OperationRecordingStart start) async {
    try {
      await _storage.writeManifest(start);
    } catch (e) {
      // Kaydı engellemez; sadece çökme kurtarması o operasyon için mümkün olmaz.
      MedLogger.warn(
        unit: _unit,
        swreq: 'SWREQ-CAM-021',
        message: 'Staging manifest yazılamadı',
        context: {'operationId': start.operationId, 'error': e.toString()},
      );
    }
  }

  @override
  Future<Result<void>> commit(OperationRecording recording) async {
    try {
      final archived = await _storage.archive(recording);
      await _put(RecordingOutboxEntry.fromRecording(archived.recording, archived.sidecarPath));
      MedLogger.info(
        unit: _unit,
        swreq: 'SWREQ-CAM-022',
        message: 'Operasyon kaydı arşivlendi',
        context: {
          'operationId': recording.operationId,
          'sidecar': archived.sidecarPath,
          'videos': archived.recording.tracks.where((t) => t.hasVideo).length,
        },
      );
      _changes.add(null);
      return const Result.ok(null);
    } catch (e, st) {
      MedLogger.error(
        unit: _unit,
        swreq: 'SWREQ-CAM-022',
        message: 'Operasyon kaydı arşivlenemedi (${recording.operationId})',
        error: e,
        stackTrace: st,
      );
      // Videolar staging'de, manifest de duruyorsa açılışta kurtarılır.
      return Result.error(UnexpectedException(message: 'Kayıt arşivlenemedi', cause: e.toString()));
    }
  }

  // ── İndeks ────────────────────────────────────────────────────────────────

  Future<List<RecordingOutboxEntry>> entries() async {
    final box = await _open();
    final result = <RecordingOutboxEntry>[];
    for (final raw in box.values) {
      try {
        result.add(RecordingOutboxEntry.fromJson(jsonDecode(raw) as Map<String, Object?>));
      } catch (_) {
        /* bozuk kayıt — reconcile sidecar'dan yeniden kurar */
      }
    }
    return result;
  }

  Future<RecordingOutboxEntry?> find(String operationId) async {
    final raw = (await _open()).get(operationId);
    return raw == null ? null : RecordingOutboxEntry.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }

  Future<void> update(RecordingOutboxEntry entry) => _put(entry);

  Future<void> remove(String operationId) async => (await _open()).delete(operationId);

  Future<void> _put(RecordingOutboxEntry e) async => (await _open()).put(e.operationId, jsonEncode(e.toJson()));

  /// Upload worker ve retention sweeper aynı kayıtları güncelliyor; birinin
  /// eski kopyası diğerinin değişikliğini ezmesin diye işlemler sıraya girer.
  Future<T> exclusive<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _lock = _lock.then((_) async {
      try {
        completer.complete(await action());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  // ── Açılışta kurtarma ─────────────────────────────────────────────────────

  /// Uygulama açılışında, HERHANGİ bir operasyon başlamadan önce çağrılır.
  ///  1. Staging'de kalmış manifest'ler (kayıt sırasında çökme) → `recovered`
  ///     olarak arşivlenir.
  ///  2. Arşivde olup indekste olmayan sidecar'lar (indeks kaybı) → indekse
  ///     `pending` olarak geri eklenir; sunucu idempotent olduğu için
  ///     önceden yüklenmişse kopya oluşmaz. [SWREQ-CAM-023]
  Future<void> recoverOnStartup() async {
    await _recoverStaging();
    await _reconcileIndex();
    await _requeueStubVerified();
    _changes.add(null);
  }

  /// API açıldıysa, API yokken sahte yanıtla "doğrulanmış" kayıtları gerçekten
  /// yüklenmek üzere yeniden kuyruğa alır. [SWREQ-CAM-036]
  Future<void> _requeueStubVerified() async {
    if (!RecordingUploadApi.isAvailable) return;
    var requeued = 0;
    for (final e in await entries()) {
      if (!e.verifiedByStub) continue;
      await _put(
        RecordingOutboxEntry(
          operationId: e.operationId,
          type: e.type,
          createdAt: e.createdAt,
          sidecarPath: e.sidecarPath,
          state: RecordingUploadState.pending,
          videos: e.videos,
          videoEvicted: e.videoEvicted,
        ),
      );
      requeued++;
    }
    if (requeued > 0) {
      MedLogger.info(
        unit: _unit,
        swreq: 'SWREQ-CAM-036',
        message: 'API öncesi biriken kayıtlar yüklenmek üzere yeniden kuyruğa alındı',
        context: {'count': requeued},
      );
    }
  }

  Future<void> _recoverStaging() async {
    for (final start in await _storage.readManifests()) {
      try {
        final files = await _storage.findStagingVideos(start.operationId);
        final tracks = <CameraTrack>[];
        DateTime? lastEnd;
        // Manifest'teki kameralar + (beklenmedik) manifest'te olmayan dosyalar.
        final cameraIds = {...start.cameras.keys, ...files.keys};
        for (final cameraId in cameraIds) {
          final file = files[cameraId];
          RecordingFile? video;
          if (file != null && await file.length() > 0) {
            final endedAt = await file.lastModified();
            video = RecordingFile(
              sessionId: start.operationId,
              path: file.path,
              startedAt: start.startedAt,
              endedAt: endedAt,
              sizeBytes: await file.length(),
              sha256: (await crypto.sha256.bind(file.openRead()).first).toString(),
              endReason: RecordingEndReason.forceKilled,
            );
            if (lastEnd == null || endedAt.isAfter(lastEnd)) lastEnd = endedAt;
          }
          tracks.add(CameraTrack(cameraId: cameraId, cameraName: start.cameras[cameraId] ?? cameraId, video: video));
        }

        await commit(
          OperationRecording(
            operationId: start.operationId,
            type: start.type,
            cabinIds: start.cabinIds,
            userId: start.userId,
            userFullName: start.userFullName,
            startedAt: start.startedAt,
            endedAt: lastEnd ?? start.startedAt,
            endReason: OperationEndReason.recovered,
            markers: const [],
            tracks: tracks,
          ),
        );
        MedLogger.warn(
          unit: _unit,
          swreq: 'SWREQ-CAM-023',
          message: 'Yarım kalan operasyon kaydı kurtarıldı',
          context: {'operationId': start.operationId, 'videos': tracks.where((t) => t.hasVideo).length},
        );
      } on FileSystemException catch (e) {
        // Çöken uygulamadan kalan ffmpeg dosyayı hâlâ tutuyor olabilir
        // (en fazla maxDuration). Bir sonraki açılışta tekrar denenir.
        MedLogger.warn(
          unit: _unit,
          swreq: 'SWREQ-CAM-023',
          message: 'Staging kaydı şu an kurtarılamadı, sonra denenecek',
          context: {'operationId': start.operationId, 'error': e.message},
        );
      }
    }
  }

  Future<void> _reconcileIndex() async {
    final box = await _open();
    final known = box.keys.cast<String>().toSet();
    var restored = 0;
    await for (final sidecar in _storage.sidecars()) {
      if (known.contains(RecordingStorage.operationIdFromSidecarName(sidecar.path))) continue;
      try {
        final r = await _storage.readSidecar(sidecar.path);
        await _put(RecordingOutboxEntry.fromRecording(r, sidecar.path));
        restored++;
      } catch (_) {
        /* okunamayan sidecar — atlanır */
      }
    }
    if (restored > 0) {
      MedLogger.warn(
        unit: _unit,
        swreq: 'SWREQ-CAM-023',
        message: 'Outbox indeksi arşivden onarıldı',
        context: {'restored': restored},
      );
    }
  }

  Future<void> dispose() async {
    await _changes.close();
    await _box?.close();
  }
}
