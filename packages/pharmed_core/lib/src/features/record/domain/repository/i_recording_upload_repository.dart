import 'package:pharmed_core/pharmed_core.dart';

/// Operasyon kayıtlarının sunucuya parçalı (resumable) yüklenmesi.
/// Bir operasyon birden fazla kameranın videosunu içerebilir; videolar
/// (operationId, cameraId) ile tanımlanır.
///
/// Sözleşme (implementasyonlar buna uymalı):
/// - Tüm çağrılar İDEMPOTENT'tir; aynı istek tekrar gelirse sunucu kopya
///   üretmez, başarı döner. [submitMetadata] tekrar çağrılırsa sunucu kaydı
///   günceller (ör. bir video sonradan "yok" olarak bildirilebilir).
/// - Sunucunun aldığı parçalar [getReceivedChunks] ile sorulur; resume'un
///   doğruluk kaynağı sunucudur.
/// - [completeVideo] hash uyuşmazsa `ServiceException(statusCode: 422)` döner
///   ve sunucu o videonun parçalarını atar.
/// - Geçici hatalar `isRetryable` olan exception'larla döner
///   (NetworkUnavailable, Timeout, 5xx).
abstract interface class IRecordingUploadRepository {
  /// [videoCameraIds]: sunucunun video bekleyeceği kameralar.
  Future<Result<void>> submitMetadata(OperationRecording recording, {required Set<String> videoCameraIds});

  Future<Result<Set<int>>> getReceivedChunks({required String operationId, required String cameraId});

  Future<Result<void>> uploadChunk({
    required String operationId,
    required String cameraId,
    required int index,
    required List<int> bytes,
  });

  Future<Result<void>> completeVideo({
    required String operationId,
    required String cameraId,
    required int totalChunks,
    required String sha256,
  });
}
