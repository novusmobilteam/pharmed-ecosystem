import 'package:pharmed_core/pharmed_core.dart';

import '../datasource/operation_recording_remote_datasource.dart';
import '../mapper/operation_recording_metadata_mapper.dart';

class OperationRecordingUploadRepositoryImpl implements IRecordingUploadRepository {
  const OperationRecordingUploadRepositoryImpl({
    required OperationRecordingRemoteDataSource dataSource,
    OperationRecordingMetadataMapper mapper = const OperationRecordingMetadataMapper(),
  }) : _dataSource = dataSource,
       _mapper = mapper;

  final OperationRecordingRemoteDataSource _dataSource;
  final OperationRecordingMetadataMapper _mapper;

  @override
  Future<Result<void>> submitMetadata(OperationRecording recording, {required Set<String> videoCameraIds}) =>
      _dataSource.submitMetadata(_mapper.toDto(recording, videoCameraIds: videoCameraIds));

  @override
  Future<Result<Set<int>>> getReceivedChunks({required String operationId, required String cameraId}) async {
    final result = await _dataSource.getReceivedChunks(operationId, cameraId);
    return result.when(
      ok: (dto) => Result.ok(_mapper.receivedChunksToEntity(dto?.receivedChunks)),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> uploadChunk({
    required String operationId,
    required String cameraId,
    required int index,
    required List<int> bytes,
  }) => _dataSource.uploadChunk(operationId, cameraId, index, bytes);

  @override
  Future<Result<void>> completeVideo({
    required String operationId,
    required String cameraId,
    required int totalChunks,
    required String sha256,
  }) => _dataSource.completeVideo(
    operationId,
    cameraId,
    CompleteVideoRequestDTO(totalChunks: totalChunks, sha256: sha256),
  );
}
