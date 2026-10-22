import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart'; // MedLogger

/// [SWREQ-DATA-CAM-001] Operasyon kayıtlarının sunucuya parçalı yüklenmesi.
///
/// Sözleşme: "Kabin Operasyon Kamera Kayıtları — Upload API Sözleşmesi".
/// Backend `/OperationRecording` ve `/api/OperationRecording` olarak yayında;
/// baseUrl zaten `/api` ile bittiği için burada önek yok.
class OperationRecordingRemoteDataSource extends BaseRemoteDataSource {
  OperationRecordingRemoteDataSource({required super.apiManager});

  @override
  String get logUnit => 'SW-UNIT-CAM';

  @override
  String get logSwreq => 'SWREQ-DATA-CAM-001';

  static const _base = '/OperationRecording';

  static String _video(String operationId, String cameraId) =>
      '$_base/${Uri.encodeComponent(operationId)}/videos/${Uri.encodeComponent(cameraId)}';

  /// GET /OperationRecording/{operationId} — kayda bağlı operationId'lerden
  /// herhangi biriyle. Çıplak JSON döner (zarfsız). [SWREQ-DATA-CAM-002]
  Future<Result<OperationRecordingDetailDTO?>> getRecording(int operationId) =>
      apiManager.get<OperationRecordingDetailDTO?>(
        '$_base/$operationId',
        parser: (json) => json is Map ? OperationRecordingDetailDTO.fromJson(json.cast<String, dynamic>()) : null,
      );

  /// GET /OperationRecording/{operationId}/videos/{cameraId} — mp4 akışı.
  /// Oynatıcı Dio dışında çektiği için tam adres ve kimlik header'ları döner.
  ({Uri uri, Map<String, String> headers}) videoRequest(int operationId, String cameraId) {
    final base = apiManager.baseUrl.endsWith('/')
        ? apiManager.baseUrl.substring(0, apiManager.baseUrl.length - 1)
        : apiManager.baseUrl;
    return (uri: Uri.parse('$base${_video('$operationId', cameraId)}'), headers: apiManager.authHeaders);
  }

  /// POST /OperationRecording — idempotent (aynı operationId tekrar gelirse günceller).
  Future<Result<void>> submitMetadata(OperationRecordingMetadataDTO dto) {
    final body = dto.toJson();
    _log('Kayıt metadata gönderiliyor', {'operationId': dto.operationId, 'body': jsonEncode(body)});
    return apiManager.post<void>(_base, data: body);
  }

  /// GET /OperationRecording/{opId}/videos/{camId}/chunks
  Future<Result<ReceivedChunksDTO?>> getReceivedChunks(String operationId, String cameraId) =>
      apiManager.get<ReceivedChunksDTO?>(
        '${_video(operationId, cameraId)}/chunks',
        parser: (json) => json is Map ? ReceivedChunksDTO.fromJson(json.cast<String, dynamic>()) : null,
      );

  /// PUT /OperationRecording/{opId}/videos/{camId}/chunks/{index} — multipart.
  /// PUT: aynı indeks tekrar gönderilirse üzerine yazılır (idempotent).
  Future<Result<void>> uploadChunk(String operationId, String cameraId, int index, List<int> bytes) {
    _log('Video parçası gönderiliyor', {
      'operationId': operationId,
      'cameraId': cameraId,
      'index': index,
      'bytes': bytes.length,
    });
    return apiManager.put<void>(
      '${_video(operationId, cameraId)}/chunks/$index',
      data: FormData.fromMap({'chunk': MultipartFile.fromBytes(bytes, filename: '$index.part')}),
    );
  }

  /// POST /OperationRecording/{opId}/videos/{camId}/complete — 422: hash uyuşmadı.
  Future<Result<void>> completeVideo(String operationId, String cameraId, CompleteVideoRequestDTO dto) {
    final body = dto.toJson();
    _log('Video tamamlama gönderiliyor', {'operationId': operationId, 'cameraId': cameraId, 'body': jsonEncode(body)});
    return apiManager.post<void>('${_video(operationId, cameraId)}/complete', data: body);
  }

  void _log(String message, Map<String, Object?> context) =>
      MedLogger.info(unit: logUnit, swreq: logSwreq, message: message, context: context);
}
