import 'package:dio/dio.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// [SWREQ-DATA-CAM-001] Operasyon kayıtlarının sunucuya parçalı yüklenmesi.
///
/// TODO(API): Yollar ve gövde biçimi backend sözleşmesi netleşince
/// güncellenecek. Şu an RecordingUploadApi.isAvailable = false olduğu için
/// use case'ler buraya hiç gelmiyor.
class OperationRecordingRemoteDataSource extends BaseRemoteDataSource {
  OperationRecordingRemoteDataSource({required super.apiManager});

  @override
  String get logUnit => 'SW-UNIT-CAM';

  @override
  String get logSwreq => 'SWREQ-DATA-CAM-001';

  static const _base = '/OperationRecording';

  static String _video(String operationId, String cameraId) =>
      '$_base/${Uri.encodeComponent(operationId)}/videos/${Uri.encodeComponent(cameraId)}';

  /// POST /OperationRecording — idempotent (aynı operationId tekrar gelirse günceller).
  Future<Result<void>> submitMetadata(OperationRecordingMetadataDTO dto) =>
      apiManager.post<void>(_base, data: dto.toJson());

  /// GET /OperationRecording/{opId}/videos/{camId}/chunks
  Future<Result<ReceivedChunksDTO?>> getReceivedChunks(String operationId, String cameraId) =>
      apiManager.get<ReceivedChunksDTO?>(
        '${_video(operationId, cameraId)}/chunks',
        parser: (json) => json is Map ? ReceivedChunksDTO.fromJson(json.cast<String, dynamic>()) : null,
      );

  /// PUT /OperationRecording/{opId}/videos/{camId}/chunks/{index} — multipart.
  /// PUT: aynı indeks tekrar gönderilirse üzerine yazılır (idempotent).
  Future<Result<void>> uploadChunk(String operationId, String cameraId, int index, List<int> bytes) =>
      apiManager.put<void>(
        '${_video(operationId, cameraId)}/chunks/$index',
        data: FormData.fromMap({'chunk': MultipartFile.fromBytes(bytes, filename: '$index.part')}),
      );

  /// POST /OperationRecording/{opId}/videos/{camId}/complete — 422: hash uyuşmadı.
  Future<Result<void>> completeVideo(String operationId, String cameraId, CompleteVideoRequestDTO dto) =>
      apiManager.post<void>('${_video(operationId, cameraId)}/complete', data: dto.toJson());
}
