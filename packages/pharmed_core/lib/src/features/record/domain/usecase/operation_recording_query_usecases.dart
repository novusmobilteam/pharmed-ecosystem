// [SWREQ-CORE-CAM-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetOperationRecordingUseCase {
  const GetOperationRecordingUseCase(this._repository);
  final IOperationRecordingRepository _repository;

  /// null → bu işlem için kayıt yok.
  Future<Result<OperationRecordingDetail?>> call(int operationId) => _repository.getByOperationId(operationId);
}

class GetRecordingVideoSourceUseCase {
  const GetRecordingVideoSourceUseCase(this._repository);
  final IOperationRecordingRepository _repository;

  RecordingVideoSource call({required int operationId, required String cameraId}) =>
      _repository.videoSource(operationId: operationId, cameraId: cameraId);
}
