import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class PrescriptionRepositoryImpl implements IPrescriptionRepository {
  PrescriptionRepositoryImpl({
    required PrescriptionRemoteDataSource dataSource,
    required PrescriptionMapper prescriptionMapper,
    required PrescriptionItemMapper prescriptionItemMapper,
    required PrescriptionItemMovementMapper prescriptionItemMovementMapper,
  }) : _dataSource = dataSource,
       _prescriptionMapper = prescriptionMapper,
       _prescriptionItemMapper = prescriptionItemMapper,
       _prescriptionItemMovementMapper = prescriptionItemMovementMapper;

  final PrescriptionRemoteDataSource _dataSource;
  final PrescriptionMapper _prescriptionMapper;
  final PrescriptionItemMapper _prescriptionItemMapper;
  final PrescriptionItemMovementMapper _prescriptionItemMovementMapper;

  @override
  Future<Result<Prescription?>> createPrescription(Prescription entity) async {
    final result = await _dataSource.createPrescription(_prescriptionMapper.toDto(entity));
    return result.when(ok: (dto) => Result.ok(_prescriptionMapper.toEntityOrNull(dto)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<PrescriptionItem?>> getPrescriptionDetail(int registrationId) async {
    final result = await _dataSource.getPrescriptionDetail(registrationId);
    return result.when(
      ok: (dto) => Result.ok(_prescriptionItemMapper.toEntityOrNull(dto)),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createPrescriptionDetail(List<PrescriptionItem> entities) async {
    final result = await _dataSource.createPrescriptionDetail(_prescriptionItemMapper.toDtoList(entities));
    return result.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<ApiResponse<List<PrescriptionItem>>?>> getUnscannedBarcodes({PagedQueryParams? params}) async {
    final result = await _dataSource.getUnscannedBarcodes();
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<PrescriptionItem>>(
          data: apiResponse?.data != null ? _prescriptionItemMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<PrescriptionItem>>?>> getScannedBarcodes() async {
    final result = await _dataSource.getScannedBarcodes();
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<PrescriptionItem>>(
          data: apiResponse?.data != null ? _prescriptionItemMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<PrescriptionItem>>?>> getDeletedBarcodes() async {
    final result = await _dataSource.getDeletedBarcodes();
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<PrescriptionItem>>(
          data: apiResponse?.data != null ? _prescriptionItemMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> scanBarcode({required int prescriptionItemId, required String qrCode}) async {
    return await _dataSource.scanBarcode(prescriptionItemId: prescriptionItemId, qrCode: qrCode);
  }

  @override
  Future<Result<ApiResponse<List<Prescription>>?>> getUnappliedPrescriptions({PagedQueryParams? params}) async {
    final result = await _dataSource.getUnappliedPrescriptions(params: params);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Prescription>>(
          data: apiResponse?.data != null ? _prescriptionMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<Prescription>>?>> getOverduePrescripitons({PagedQueryParams? params}) async {
    final result = await _dataSource.getOverduePrescripitons(params: params);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Prescription>>(
          data: apiResponse?.data != null ? _prescriptionMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<PrescriptionItem>>> getUnappliedPrescriptionDetail(int prescriptionId) async {
    final result = await _dataSource.getUnappliedPrescriptionDetail(prescriptionId);
    return result.when(
      ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos ?? [])),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<Prescription>>> getPatientPrescriptions(int hospitalizationId) async {
    final result = await _dataSource.getPatientPrescriptions(hospitalizationId);
    return result.when(
      ok: (dtos) => Result.ok(_prescriptionMapper.toEntityList(dtos ?? [])),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> checkPrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await _dataSource.checkPrescriptionRequests(prescriptionId, ids);
  }

  @override
  Future<Result<void>> approvePrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await _dataSource.approvePrescriptionRequests(prescriptionId, ids);
  }

  @override
  Future<Result<void>> cancelPrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await _dataSource.cancelPrescriptionRequests(prescriptionId, ids);
  }

  @override
  Future<Result<void>> rejectPrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await _dataSource.rejectPrescriptionRequests(prescriptionId, ids);
  }

  @override
  Future<Result<void>> rejectApprovedRequests(int prescriptionId, List<int> ids) async {
    return await _dataSource.rejectApprovedRequests(prescriptionId, ids);
  }

  @override
  Future<Result<void>> updatePrescriptionItem(PrescriptionItem entity) async {
    return await _dataSource.updatePrescriptionItem(_prescriptionItemMapper.toDto(entity));
  }

  @override
  Future<Result<void>> deletePrescription(int prescriptionId) async {
    return await _dataSource.deletePrescription(prescriptionId);
  }

  @override
  Future<Result<void>> deleteUnscannedBarcode({required int prescriptionItemId, required String description}) async {
    return await _dataSource.deleteUnscannedBarcode(prescriptionItemId: prescriptionItemId, description: description);
  }

  @override
  Future<Result<void>> toggleWarning(int prescriptionId) async {
    return await _dataSource.toggleWarning(prescriptionId);
  }

  @override
  Future<Result<List<PrescriptionItem>>> getDrugActivity() async {
    final result = await _dataSource.getDrugActivity();
    return result.when(
      ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos ?? [])),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<PrescriptionItemMovement>>?>> getCurrentStationDrugActivity({
    PagedQueryParams? params,
  }) async {
    final result = await _dataSource.getCurrentStationDrugActivity(params: params);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<PrescriptionItemMovement>>(
          data: apiResponse?.data != null ? _prescriptionItemMovementMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<PrescriptionItem>>> getEmergencyPatientMedicines(int hospitalizationId) async {
    final result = await _dataSource.getEmergencyPatientMedicines(hospitalizationId);
    return result.when(
      ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos ?? [])),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<PrescriptionItem>>> getDailyJobList(int hospitalizationId) async {
    final result = await _dataSource.getDailyJobList(hospitalizationId);
    return result.when(
      ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos ?? [])),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<PrescriptionItem>>?>> getPatientPrescriptionHistory(
    int patientId, {
    PagedQueryParams? params,
  }) async {
    final result = await _dataSource.getPatientPrescriptionHistory(patientId, params: params);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<PrescriptionItem>>(
          data: apiResponse?.data != null ? _prescriptionItemMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<String>> assignRfidTag({required int prescriptionItemId, required String epc}) async {
    final result = await _dataSource.assignRfidTag(prescriptionItemId: prescriptionItemId, epc: epc);
    return result.when(ok: (dtos) => Result.ok(epc), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteRfidTag({required int prescriptionItemId}) async {
    final result = await _dataSource.deleteRfidTag(prescriptionItemId: prescriptionItemId);
    return result.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<PrescriptionItemMovement>>> getPrescriptionItemMovements(int prescriptionItemId) async {
    final result = await _dataSource.getPrescriptionItemMovements(prescriptionItemId);
    return result.when(
      ok: (dtos) => Result.ok(_prescriptionItemMovementMapper.toEntityList(dtos ?? [])),
      error: (e) => Result.error(e),
    );
  }
}
