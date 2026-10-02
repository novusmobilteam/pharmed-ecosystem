import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart'; // MedLogger

import 'package:pharmed_client/core/recording/outbox/hive_recording_outbox.dart';
import 'package:pharmed_client/core/recording/recording_config.dart';
import 'package:pharmed_client/core/recording/storage/recording_storage.dart';

/// Outbox'taki kayıtları arka planda sunucuya yükler. [SWREQ-CAM-030]
///
/// - Tek seferde tek kayıt, tek video, tek parça (single-flight): bellek
///   kullanımı en fazla bir parça (chunkSize) kadar, dosya boyutundan bağımsız.
/// - Kaldığı yerden devam: hangi parçaların gittiğini SUNUCUYA sorar; tamamlanan
///   videolar indekste işaretlenir, kısmi ilerleme kaybolmaz.
/// - Geçici hatada üstel geri çekilme + jitter; kalıcı hatada `rejected`.
/// - Kabin operasyonu sürerken DURAKLAR: upload, operasyonun API çağrılarıyla
///   bant genişliği ve bağlantı havuzu için yarışmamalı.
class RecordingUploadWorker {
  RecordingUploadWorker({
    required HiveRecordingOutbox outbox,
    required RecordingStorage storage,
    required SubmitRecordingMetadataUseCase submitMetadata,
    required GetReceivedRecordingChunksUseCase getReceivedChunks,
    required UploadRecordingChunkUseCase uploadChunk,
    required CompleteRecordingVideoUseCase completeVideo,
    required RecordingUploadConfig config,
    required bool Function() isBusy,
    DateTime Function() clock = DateTime.now,
    Random? random,
  }) : _outbox = outbox,
       _storage = storage,
       _submitMetadata = submitMetadata,
       _getReceivedChunks = getReceivedChunks,
       _uploadChunk = uploadChunk,
       _completeVideo = completeVideo,
       _config = config,
       _isBusy = isBusy,
       _clock = clock,
       _random = random ?? Random();

  static const _unit = 'SW-UNIT-CAM';

  final HiveRecordingOutbox _outbox;
  final RecordingStorage _storage;
  final SubmitRecordingMetadataUseCase _submitMetadata;
  final GetReceivedRecordingChunksUseCase _getReceivedChunks;
  final UploadRecordingChunkUseCase _uploadChunk;
  final CompleteRecordingVideoUseCase _completeVideo;
  final RecordingUploadConfig _config;
  final bool Function() _isBusy;
  final DateTime Function() _clock;
  final Random _random;

  StreamSubscription<void>? _changesSub;
  Timer? _timer;
  bool _running = false;
  bool _rerunRequested = false;
  bool _disposed = false;

  void start() {
    if (!_config.enabled) {
      MedLogger.info(
        unit: _unit,
        swreq: 'SWREQ-CAM-030',
        message: 'Kayıt upload kapalı (RECORDING_UPLOAD_ENABLED=false); kayıtlar lokalde birikir',
      );
      return;
    }
    _changesSub = _outbox.changes.listen((_) => kick());
    _timer = Timer.periodic(_config.pollInterval, (_) => kick());
    kick();
  }

  /// Kuyruğu işlemeyi tetikler. Zaten çalışıyorsa bir tur daha işaretler.
  void kick() {
    if (_disposed || !_config.enabled) return;
    if (_running) {
      _rerunRequested = true;
      return;
    }
    unawaited(_drain());
  }

  Future<void> _drain() async {
    _running = true;
    try {
      do {
        _rerunRequested = false;
        final now = _clock();
        final due = (await _outbox.entries()).where((e) => e.isDue(now)).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // en eski önce
        for (final candidate in due) {
          if (_disposed || _isBusy()) return;
          await _outbox.exclusive(() async {
            // Kilit beklenirken sweeper kaydı değiştirmiş/silmiş olabilir.
            final entry = await _outbox.find(candidate.operationId);
            if (entry != null && entry.isDue(_clock())) await _process(entry);
          });
        }
      } while (_rerunRequested && !_disposed);
    } catch (e, st) {
      MedLogger.error(
        unit: _unit,
        swreq: 'SWREQ-CAM-030',
        message: 'Upload turu beklenmeyen hata',
        error: e,
        stackTrace: st,
      );
    } finally {
      _running = false;
    }
  }

  Future<void> _process(RecordingOutboxEntry entry) async {
    var current = entry;
    final recording = await _storage.readSidecar(current.sidecarPath);

    // 1) Metadata
    if (current.state == RecordingUploadState.pending) {
      final result = await _submitMetadata(
        SubmitRecordingMetadataParams(recording: recording, videoCameraIds: current.expectedVideoCameraIds),
      );
      if (await _handleError(current, result)) return;
      current = current.copyWith(state: RecordingUploadState.metadataSent);
      await _outbox.update(current);
    }

    // 2) Videolar — tamamlanmamış olanlar, sırayla
    for (final video in current.pendingVideos) {
      final track = recording.tracks.where((t) => t.cameraId == video.cameraId).firstOrNull;
      final sha = track?.video?.sha256;
      if (sha == null) {
        await _reject(current, 'Sidecar\'da ${video.cameraId} videosunun hash\'i yok');
        return;
      }

      final outcome = await _uploadVideo(current, video, sha);
      switch (outcome) {
        case _VideoOutcome.done:
          current = current.copyWith(completedVideos: {...current.completedVideos, video.cameraId});
          await _outbox.update(current);
        case _VideoOutcome.paused:
        case _VideoOutcome.failed:
          return; // durum _uploadVideo içinde güncellendi
      }
    }

    // 3) Hepsi tamam
    await _markVerified(current);
  }

  Future<_VideoOutcome> _uploadVideo(RecordingOutboxEntry entry, OutboxVideo video, String sha256) async {
    final file = File(video.path);
    final size = await file.length();
    final totalChunks = max(1, (size / _config.chunkSize).ceil());

    final ref = RecordingVideoRef(operationId: entry.operationId, cameraId: video.cameraId);
    final received = await _getReceivedChunks(ref);
    if (await _handleError(entry, received)) return _VideoOutcome.failed;
    final have = received.data ?? const <int>{};

    final raf = await file.open();
    try {
      for (var i = 0; i < totalChunks; i++) {
        if (have.contains(i)) continue;
        if (_disposed || _isBusy()) return _VideoOutcome.paused; // operasyon başladı → sonra devam
        await raf.setPosition(i * _config.chunkSize);
        final bytes = await raf.read(min(_config.chunkSize, size - i * _config.chunkSize));
        final r = await _uploadChunk(UploadRecordingChunkParams(video: ref, index: i, bytes: bytes));
        if (await _handleError(entry, r)) return _VideoOutcome.failed;
      }
    } finally {
      await raf.close();
    }

    final complete = await _completeVideo(
      CompleteRecordingVideoParams(video: ref, totalChunks: totalChunks, sha256: sha256),
    );
    if (complete.isError) {
      final e = _errorOf(complete);
      if (e is ServiceException && e.statusCode == 422) {
        await _onHashMismatch(entry, video.cameraId);
      } else {
        await _handleError(entry, complete);
      }
      return _VideoOutcome.failed;
    }
    return _VideoOutcome.done;
  }

  Future<void> _markVerified(RecordingOutboxEntry e) async {
    final stub = !RecordingUploadApi.isAvailable;
    await _outbox.update(
      e.copyWith(
        state: RecordingUploadState.verified,
        verifiedByStub: stub,
        attempts: 0,
        clearNextAttempt: true,
        clearError: true,
      ),
    );
    MedLogger.info(
      unit: _unit,
      swreq: 'SWREQ-CAM-030',
      message: stub
          ? 'Operasyon kaydı upload akışından geçti (API yok — sunucuya GÖNDERİLMEDİ)'
          : 'Operasyon kaydı sunucuya yüklendi ve doğrulandı',
      context: {'operationId': e.operationId, 'videos': e.completedVideos.length, 'videoBytes': e.videoBytes},
    );
  }

  Future<void> _onHashMismatch(RecordingOutboxEntry e, String cameraId) async {
    final mismatches = e.hashMismatches + 1;
    if (mismatches >= _config.maxHashMismatches) {
      await _reject(
        e.copyWith(hashMismatches: mismatches),
        '$cameraId videosu için sunucu hash doğrulaması $mismatches kez başarısız',
      );
      return;
    }
    // Sunucu parçaları attı; o video baştan yüklenecek.
    await _outbox.update(
      e.copyWith(
        hashMismatches: mismatches,
        nextAttemptAt: _clock().add(_config.baseBackoff),
        lastError: 'hash mismatch ($cameraId)',
      ),
    );
    MedLogger.warn(
      unit: _unit,
      swreq: 'SWREQ-CAM-031',
      message: 'Sunucu video hash\'ini reddetti, yeniden yüklenecek',
      context: {'operationId': e.operationId, 'cameraId': cameraId, 'mismatches': mismatches},
    );
  }

  /// Hata yoksa false. Hata varsa durumu günceller ve true döner.
  Future<bool> _handleError(RecordingOutboxEntry e, Result<Object?> result) async {
    if (!result.isError) return false;
    final error = _errorOf(result);

    if (error.isRetryable) {
      final attempts = e.attempts + 1;
      final delay = _backoff(attempts);
      await _outbox.update(
        e.copyWith(attempts: attempts, nextAttemptAt: _clock().add(delay), lastError: error.message),
      );
      MedLogger.warn(
        unit: _unit,
        swreq: 'SWREQ-CAM-031',
        message: 'Upload geçici hata, yeniden denenecek',
        context: {
          'operationId': e.operationId,
          'attempts': attempts,
          'retryInSec': delay.inSeconds,
          'error': error.message,
        },
      );
    } else {
      await _reject(e, error.message);
    }
    return true;
  }

  Future<void> _reject(RecordingOutboxEntry e, String reason) async {
    await _outbox.update(e.copyWith(state: RecordingUploadState.rejected, lastError: reason));
    MedLogger.error(
      unit: _unit,
      swreq: 'SWREQ-CAM-031',
      message: 'Operasyon kaydı kalıcı olarak reddedildi (${e.operationId}): $reason',
      error: reason,
    );
  }

  /// Üstel geri çekilme + "equal jitter": aynı anda düşen istasyonların
  /// sunucuya senkron yüklenmesini (thundering herd) önler.
  Duration _backoff(int attempts) {
    final exp = _config.baseBackoff.inMilliseconds * pow(2, min(attempts - 1, 16));
    final capped = min(exp.toDouble(), _config.maxBackoff.inMilliseconds.toDouble());
    final jittered = capped / 2 + _random.nextDouble() * capped / 2;
    return Duration(milliseconds: jittered.round());
  }

  static AppException _errorOf(Result<Object?> r) => r.when(ok: (_) => const UnexpectedException(), error: (e) => e);

  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    await _changesSub?.cancel();
  }
}

enum _VideoOutcome { done, paused, failed }
