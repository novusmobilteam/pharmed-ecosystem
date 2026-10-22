import 'package:pharmed_core/pharmed_core.dart';

/// Sunucudaki operasyon kayıtlarını okuma (izleme). Yükleme için
/// [IRecordingUploadRepository]. [SWREQ-CORE-CAM-002]
abstract interface class IOperationRecordingRepository {
  /// Kayda bağlı sunucu operationId'lerinden herhangi biriyle kaydı getirir.
  /// Bu işlem için kayıt yoksa `Result.ok(null)`.
  Future<Result<OperationRecordingDetail?>> getByOperationId(int operationId);

  /// Bir kameranın videosunu akışla oynatmak için kaynak.
  RecordingVideoSource videoSource({required int operationId, required String cameraId});
}
