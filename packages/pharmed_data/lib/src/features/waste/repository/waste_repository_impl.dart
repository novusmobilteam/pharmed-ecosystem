import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class WasteRepositoryImpl implements IWasteRepository {
  final WasteRemoteDataSource _dataSource;
  final MedicineAssignmentMapper _assignmentMapper;
  final PrescriptionItemMapper _prescriptionItemMapper;

  WasteRepositoryImpl({
    required WasteRemoteDataSource dataSource,
    required MedicineAssignmentMapper assignmentMapper,
    required PrescriptionItemMapper prescriptionItemMapper,
  }) : _dataSource = dataSource,
       _assignmentMapper = assignmentMapper,
       _prescriptionItemMapper = prescriptionItemMapper;

  @override
  Future<Result<List<PrescriptionItem>>> getMasterDisposables({required int hospitalizationId}) async {
    final r = await _dataSource.getMasterDisposables(hospitalizationId: hospitalizationId);
    return r.when(
      ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos)),
      error: (err) => Result.error(err),
    );
  }

  @override
  Future<Result<List<MedicineAssignment>>> getMasterDisposableMaterials() async {
    final r = await _dataSource.getMasterDisposableMaterials();
    return r.when(ok: (dtos) => Result.ok(_assignmentMapper.toEntityList(dtos)), error: (err) => Result.error(err));
  }

  @override
  Future<Result<void>> masterWastage(Map<String, dynamic> data) async {
    return await _dataSource.masterWastage(data);
  }

  @override
  Future<Result<void>> masterDestruction(Map<String, dynamic> data) async {
    return await _dataSource.masterDestruction(data);
  }

  @override
  Future<Result<void>> masterDisposeMaterial(List<Map<String, dynamic>> data) async {
    return await _dataSource.masterDisposeMaterial(data);
  }

  @override
  Future<Result<List<PrescriptionItem>>> getMobileDisposables({required int hospitalizationId}) async {
    final r = await _dataSource.getMobileDisposables(hospitalizationId: hospitalizationId);
    return r.when(
      ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos)),
      error: (err) => Result.error(err),
    );
  }

  @override
  Future<Result<void>> mobileWastage(Map<String, dynamic> data) async {
    return await _dataSource.mobileWastage(data);
  }

  @override
  Future<Result<void>> mobileDestruction(Map<String, dynamic> data) async {
    return await _dataSource.mobileDestruction(data);
  }
}
