import 'package:pharmed_core/pharmed_core.dart';

import '../datasource/operation_recording_remote_datasource.dart';
import '../mapper/operation_recording_detail_mapper.dart';

class OperationRecordingRepositoryImpl implements IOperationRecordingRepository {
  const OperationRecordingRepositoryImpl({
    required OperationRecordingRemoteDataSource dataSource,
    OperationRecordingDetailMapper mapper = const OperationRecordingDetailMapper(),
  }) : _dataSource = dataSource,
       _mapper = mapper;

  final OperationRecordingRemoteDataSource _dataSource;
  final OperationRecordingDetailMapper _mapper;

  @override
  Future<Result<OperationRecordingDetail?>> getByOperationId(int operationId) async {
    final result = await _dataSource.getRecording(operationId);
    return result.when(
      ok: (dto) => Result.ok(dto == null ? null : _mapper.toEntity(dto)),
      // 404: bu işlem için kayıt yok — hata değil, boş durum.
      error: (e) => e is ServiceException && e.statusCode == 404 ? const Result.ok(null) : Result.error(e),
    );
  }

  @override
  RecordingVideoSource videoSource({required int operationId, required String cameraId}) {
    final request = _dataSource.videoRequest(operationId, cameraId);
    return RecordingVideoSource(uri: request.uri, headers: request.headers);
  }
}
