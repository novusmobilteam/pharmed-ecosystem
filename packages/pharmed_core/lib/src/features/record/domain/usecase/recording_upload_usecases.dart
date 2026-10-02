import 'package:pharmed_core/pharmed_core.dart';

/// Kayıt upload API'sinin durumu.
///
/// `false` iken use case'ler sunucuya GİTMEDEN başarı döner; tüm upload hattı
/// (outbox → worker → use case) uçtan uca çalışır ama veri hiçbir yere
/// gönderilmez. Bu sırada "doğrulanan" kayıtlar `verifiedByStub` işaretlenir:
/// saklama kuralı onları silmez, API açılınca otomatik yeniden yüklenirler.
///
/// Backend endpoint'leri tamamlanınca `true` yapılır — başka değişiklik gerekmez.
abstract final class RecordingUploadApi {
  static const bool isAvailable = false;
}

// ── Metadata ────────────────────────────────────────────────────────────────

class SubmitRecordingMetadataParams {
  const SubmitRecordingMetadataParams({required this.recording, required this.videoCameraIds});
  final OperationRecording recording;

  /// Sunucunun video bekleyeceği kameralar.
  final Set<String> videoCameraIds;
}

/// [SWREQ-CAM-032] Operasyon kaydının metadata'sını gönderir (idempotent).
class SubmitRecordingMetadataUseCase {
  const SubmitRecordingMetadataUseCase(this._repository);
  final IRecordingUploadRepository _repository;

  Future<Result<void>> call(SubmitRecordingMetadataParams params) async {
    if (params.recording.operationId.trim().isEmpty) {
      return const Result.error(ValidationException(message: 'operationId boş', field: 'operationId'));
    }
    final unknown = params.videoCameraIds.difference(params.recording.tracks.map((t) => t.cameraId).toSet());
    if (unknown.isNotEmpty) {
      return Result.error(
        ValidationException(
          message: 'Kayıtta olmayan kamera için video bildirildi',
          field: 'videoCameraIds',
          value: unknown.toList(),
        ),
      );
    }
    if (!RecordingUploadApi.isAvailable) return const Result.ok(null);
    return _repository.submitMetadata(params.recording, videoCameraIds: params.videoCameraIds);
  }
}

// ── Video parçaları ─────────────────────────────────────────────────────────

class RecordingVideoRef {
  const RecordingVideoRef({required this.operationId, required this.cameraId});
  final String operationId;
  final String cameraId;

  ValidationException? validate() {
    if (operationId.trim().isEmpty) return const ValidationException(message: 'operationId boş', field: 'operationId');
    if (cameraId.trim().isEmpty) return const ValidationException(message: 'cameraId boş', field: 'cameraId');
    return null;
  }
}

/// [SWREQ-CAM-033] Sunucunun aldığı parçalar — resume'un doğruluk kaynağı.
class GetReceivedRecordingChunksUseCase {
  const GetReceivedRecordingChunksUseCase(this._repository);
  final IRecordingUploadRepository _repository;

  Future<Result<Set<int>>> call(RecordingVideoRef video) async {
    final invalid = video.validate();
    if (invalid != null) return Result.error(invalid);
    if (!RecordingUploadApi.isAvailable) return const Result.ok(<int>{});
    return _repository.getReceivedChunks(operationId: video.operationId, cameraId: video.cameraId);
  }
}

class UploadRecordingChunkParams {
  const UploadRecordingChunkParams({required this.video, required this.index, required this.bytes});
  final RecordingVideoRef video;
  final int index;
  final List<int> bytes;
}

/// [SWREQ-CAM-034] Tek bir video parçasını yükler (idempotent).
class UploadRecordingChunkUseCase {
  const UploadRecordingChunkUseCase(this._repository);
  final IRecordingUploadRepository _repository;

  Future<Result<void>> call(UploadRecordingChunkParams params) async {
    final invalid = params.video.validate();
    if (invalid != null) return Result.error(invalid);
    if (params.index < 0) {
      return Result.error(ValidationException(message: 'Parça indeksi negatif', field: 'index', value: params.index));
    }
    if (params.bytes.isEmpty) {
      return const Result.error(ValidationException(message: 'Boş parça', field: 'bytes'));
    }
    if (!RecordingUploadApi.isAvailable) return const Result.ok(null);
    return _repository.uploadChunk(
      operationId: params.video.operationId,
      cameraId: params.video.cameraId,
      index: params.index,
      bytes: params.bytes,
    );
  }
}

class CompleteRecordingVideoParams {
  const CompleteRecordingVideoParams({required this.video, required this.totalChunks, required this.sha256});
  final RecordingVideoRef video;
  final int totalChunks;
  final String sha256;
}

/// [SWREQ-CAM-035] Sunucuya videonun bittiğini bildirir; sunucu parçaları
/// birleştirip hash'i doğrular (uyuşmazsa 422).
class CompleteRecordingVideoUseCase {
  const CompleteRecordingVideoUseCase(this._repository);
  final IRecordingUploadRepository _repository;

  static final _sha256Hex = RegExp(r'^[a-f0-9]{64}$');

  Future<Result<void>> call(CompleteRecordingVideoParams params) async {
    final invalid = params.video.validate();
    if (invalid != null) return Result.error(invalid);
    if (params.totalChunks <= 0) {
      return Result.error(
        ValidationException(message: 'Parça sayısı geçersiz', field: 'totalChunks', value: params.totalChunks),
      );
    }
    if (!_sha256Hex.hasMatch(params.sha256)) {
      return Result.error(
        ValidationException(message: 'SHA-256 biçimi geçersiz', field: 'sha256', value: params.sha256),
      );
    }
    if (!RecordingUploadApi.isAvailable) return const Result.ok(null);
    return _repository.completeVideo(
      operationId: params.video.operationId,
      cameraId: params.video.cameraId,
      totalChunks: params.totalChunks,
      sha256: params.sha256,
    );
  }
}
