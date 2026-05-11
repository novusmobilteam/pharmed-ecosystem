import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class IntakeRepositoryImpl implements IIntakeRepository {
  const IntakeRepositoryImpl({
    required IntakeRemoteDataSource dataSource,
    required IntakeItemMapper intakeItemMapper,
    required PatientIntakeItemMapper patientIntakeItemMapper,
  }) : _dataSource = dataSource,
       _intakeItemMapper = intakeItemMapper,
       _patientIntakeItemMapper = patientIntakeItemMapper;

  final IntakeRemoteDataSource _dataSource;
  final IntakeItemMapper _intakeItemMapper;
  final PatientIntakeItemMapper _patientIntakeItemMapper;

  @override
  Future<Result<void>> checkFreeIntake(Map<String, dynamic> data) async {
    return await _dataSource.checkFreeIntake(data);
  }

  @override
  Future<Result<void>> checkOrderedIntake(Map<String, dynamic> data) async {
    return await _dataSource.checkOrderedIntake(data);
  }

  @override
  Future<Result<void>> checkOrderlessIntake(Map<String, dynamic> data) async {
    return await _dataSource.checkOrderlessIntake(data);
  }

  @override
  Future<Result<void>> completeFreeIntake(Map<String, dynamic> data) async {
    return await _dataSource.completeFreeIntake(data);
  }

  @override
  Future<Result<void>> completeOrderedIntake(Map<String, dynamic> data) async {
    return await _dataSource.completeOrderedIntake(data);
  }

  @override
  Future<Result<void>> completeOrderlessIntake(Map<String, dynamic> data) async {
    return await _dataSource.completeOrderlessIntake(data);
  }

  @override
  Future<Result<List<PatientMedicineIntakeItem>>> getPatientMedicines({required int hospitalizationId}) async {
    final res = await _dataSource.getPatientMedicines(hospitalizationId: hospitalizationId);
    return res.when(
      ok: (dtos) => Result.ok(_patientIntakeItemMapper.toEntityList(dtos ?? [])),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<MedicineIntakeItem>>> getIntakeItems({required int hospitalizationId}) async {
    final res = await _dataSource.getIntakeItems(hospitalizationId: hospitalizationId);
    return res.when(ok: (dtos) => Result.ok(_intakeItemMapper.toEntityList(dtos ?? [])), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> intakePatientMedicine({required int id}) async {
    return await _dataSource.intakePatientMedicine(id: id);
  }

  @override
  Future<Result<void>> definePatientMedicine(Map<String, dynamic> data) async {
    return await _dataSource.definePatientMedicine(data);
  }

  @override
  Future<Result<void>> checkMobileIntake(List<Map<String, dynamic>> data) async {
    return await _dataSource.checkMobileIntake(data);
  }

  @override
  Future<Result<void>> completeMobileIntake(List<Map<String, dynamic>> data) async {
    return await _dataSource.completeMobileIntake(data);
  }
}
