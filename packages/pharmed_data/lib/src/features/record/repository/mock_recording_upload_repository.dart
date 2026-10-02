import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart' as crypto;
import 'package:path/path.dart' as p;
import 'package:pharmed_core/pharmed_core.dart';

/// API hazır olana kadar sunucu davranışını taklit eder. Gerçek API geldiğinde
/// Mock flavor içindir (proje kuralı: mock repository katmanında).
///
/// Gerçekçi olsun diye:
/// - Parçaları diske yazar (bellekte tutmaz), complete'te birleştirip
///   SHA-256 doğrular → 422 yolu gerçekten test edilir.
/// - İdempotent: aynı metadata/parça tekrar gelirse hata vermez.
/// - [failureRate] oranında 503 / ağ hatası üretir → retry + backoff test edilir.
class MockRecordingUploadRepository implements IRecordingUploadRepository {
  MockRecordingUploadRepository({
    required String serverRootPath,
    this.failureRate = 0.1,
    this.latency = const Duration(milliseconds: 150),
    Random? random,
  }) : _root = Directory(serverRootPath),
       _random = random ?? Random();

  final Directory _root;
  final double failureRate;
  final Duration latency;
  final Random _random;

  final _expected = <String, Set<String>>{}; // operationId → video beklenen kameralar

  Directory _chunkDir(String opId, String cameraId) => Directory(p.join(_root.path, 'chunks', opId, cameraId));

  @override
  Future<Result<void>> submitMetadata(OperationRecording recording, {required Set<String> videoCameraIds}) async {
    final fail = await _simulate();
    if (fail != null) return Result.error(fail);
    _expected[recording.operationId] = videoCameraIds; // idempotent: tekrar gelirse günceller
    return const Result.ok(null);
  }

  @override
  Future<Result<Set<int>>> getReceivedChunks({required String operationId, required String cameraId}) async {
    final fail = await _simulate();
    if (fail != null) return Result.error(fail);
    final dir = _chunkDir(operationId, cameraId);
    if (!await dir.exists()) return const Result.ok(<int>{});
    final indexes = <int>{};
    await for (final f in dir.list()) {
      final i = int.tryParse(p.basenameWithoutExtension(f.path));
      if (i != null) indexes.add(i);
    }
    return Result.ok(indexes);
  }

  @override
  Future<Result<void>> uploadChunk({
    required String operationId,
    required String cameraId,
    required int index,
    required List<int> bytes,
  }) async {
    if (!(_expected[operationId]?.contains(cameraId) ?? false)) {
      return const Result.error(ServiceException(message: 'Bu kamera için video beklenmiyor', statusCode: 404));
    }
    final fail = await _simulate();
    if (fail != null) return Result.error(fail);
    final dir = _chunkDir(operationId, cameraId);
    await dir.create(recursive: true);
    await File(p.join(dir.path, '$index.part')).writeAsBytes(bytes, flush: true);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> completeVideo({
    required String operationId,
    required String cameraId,
    required int totalChunks,
    required String sha256,
  }) async {
    final fail = await _simulate();
    if (fail != null) return Result.error(fail);

    final dir = _chunkDir(operationId, cameraId);
    final target = File(p.join(_root.path, 'videos', operationId, '$cameraId.mp4'));
    await target.parent.create(recursive: true);
    final sink = target.openWrite();
    try {
      for (var i = 0; i < totalChunks; i++) {
        final part = File(p.join(dir.path, '$i.part'));
        if (!await part.exists()) {
          return Result.error(ServiceException(message: 'Eksik parça: $i', statusCode: 409));
        }
        await sink.addStream(part.openRead());
      }
    } finally {
      await sink.close();
    }

    final actual = (await crypto.sha256.bind(target.openRead()).first).toString();
    if (actual != sha256) {
      await dir.delete(recursive: true); // sözleşme: 422'de parçalar atılır
      await target.delete();
      return const Result.error(ServiceException(message: 'Hash uyuşmuyor', statusCode: 422));
    }
    await dir.delete(recursive: true);
    return const Result.ok(null);
  }

  Future<AppException?> _simulate() async {
    await Future<void>.delayed(latency);
    if (_random.nextDouble() >= failureRate) return null;
    return _random.nextBool()
        ? const ServiceException(message: 'Service Unavailable (mock)', statusCode: 503)
        : const NetworkUnavailableException(message: 'Ağ yok (mock)');
  }
}
