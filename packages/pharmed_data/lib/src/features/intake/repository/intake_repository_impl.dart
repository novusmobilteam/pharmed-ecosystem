import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class IntakeRepositoryImpl implements IIntakeRepository {
  const IntakeRepositoryImpl({
    required IntakeRemoteDataSource dataSource,
    required CabinTargetedRxItemMapper intakeItemMapper,
    required PatientIntakeItemMapper patientIntakeItemMapper,
    required EquivalentMedicineMapper eqMapper,
    required OtherStationMedicineMapper otherMapper,
    required RedirectedIntakeOrderMapper redirectMapper,
  }) : _dataSource = dataSource,
       _intakeItemMapper = intakeItemMapper,
       _patientIntakeItemMapper = patientIntakeItemMapper,
       _eqMapper = eqMapper,
       _otherMapper = otherMapper,
       _redirectMapper = redirectMapper;

  final IntakeRemoteDataSource _dataSource;
  final CabinTargetedRxItemMapper _intakeItemMapper;
  final PatientIntakeItemMapper _patientIntakeItemMapper;
  final EquivalentMedicineMapper _eqMapper;
  final OtherStationMedicineMapper _otherMapper;
  final RedirectedIntakeOrderMapper _redirectMapper;

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
  Future<Result<List<CabinTargetedPrescriptionItem>>> getIntakeItems({required int hospitalizationId}) async {
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

  @override
  Future<Result<void>> checkEquivalentIntake(Map<String, dynamic> data) async {
    return await _dataSource.checkEquivalentIntake(data);
  }

  @override
  Future<Result<void>> completeEquivalentIntake(Map<String, dynamic> data) async {
    return await _dataSource.completeEquivalentIntake(data);
  }

  @override
  Future<Result<List<EquivalentMedicine>>> getEquivalentMedicines({required int prescriptionDetailId}) async {
    final res = await _dataSource.getEquivalentMedicines(prescriptionDetailId: prescriptionDetailId);
    return res.when(ok: (dtos) => Result.ok(_eqMapper.toEntityList(dtos ?? [])), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<OtherStationMedicine>>> getOtherStationMedicines({required int prescriptionDetailId}) async {
    final res = await _dataSource.getOtherStationMedicines(prescriptionDetailId: prescriptionDetailId);
    return res.when(ok: (dtos) => Result.ok(_otherMapper.toEntityList(dtos ?? [])), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> redirectIntake(Map<String, dynamic> data) async {
    return await _dataSource.redirectIntake(data);
  }

  @override
  Future<Result<List<RedirectedIntakeOrder>>> getRedirectedIntakeOrders(int hospitalizationId) async {
    final res = await _dataSource.getRedirectedIntakeOrders(hospitalizationId);
    return res.when(ok: (dtos) => Result.ok(_redirectMapper.toEntityList(dtos ?? [])), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> checkRedirectedIntake(int referralId) async {
    return await _dataSource.checkRedirectedIntake(referralId);
  }

  @override
  Future<Result<void>> completeRedirectedIntake({required int referralId, double? censusQuantity}) async {
    return await _dataSource.completeRedirectedIntake(referralId: referralId, censusQuantity: censusQuantity);
  }
}
