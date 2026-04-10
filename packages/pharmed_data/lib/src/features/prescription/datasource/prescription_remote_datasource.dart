import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class PrescriptionRemoteDataSource extends BaseRemoteDataSource {
  PrescriptionRemoteDataSource({required super.apiManager});

  static const String _base = '/Prescription';
  static const String _detail = '/Prescription/detail/bulk';
  static const String _unapplied = '$_base/uncollectedPrescriptionMaster';

  static String _unappliedDetail(int id) => '/Prescription/uncollectedPrescriptionDetail/$id';

  @override
  String get logSwreq => 'SWREQ-DATA-PRESCRIPTION-001';

  @override
  String get logUnit => 'SW-UNIT-PRESCRIPTION';

  Future<Result<PrescriptionDTO?>> createPrescription(PrescriptionDTO dto) {
    return createRequest<PrescriptionDTO?>(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(PrescriptionDTO.fromJson),
      successLog: 'Prescription created',
      envelope: ResponseEnvelope.apiResponse,
    );
  }

  Future<Result<List<PrescriptionItemDTO>?>> getPrescriptionDetail(int prescriptionId) {
    return fetchRequest<List<PrescriptionItemDTO>>(
      path: '$_base/detail/$prescriptionId/getAll',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
      successLog: 'Prescription items fetched',
      emptyLog: 'No prescription items',
    );
  }

  Future<Result<void>> createPrescriptionDetail(List<PrescriptionItemDTO> items) {
    final body = {'prescriptionDetails': items.map((e) => e.toJson()).toList()};

    return createRequest<void>(
      path: _detail,
      body: body,
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Prescription items created',
    );
  }

  Future<Result<ApiResponse<List<PrescriptionItemDTO>>?>> getUnscannedBarcodes({
    int? skip,
    int? take,
    String? search,
  }) async {
    return await fetchRequest(
      path: '/Prescription/detail/unReadQrCode',
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['barcode'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(PrescriptionItemDTO.fromJson),
    );
  }

  Future<Result<ApiResponse<List<PrescriptionItemDTO>>?>> getScannedBarcodes({
    int? skip,
    int? take,
    String? search,
  }) async {
    return await fetchRequest<ApiResponse<List<PrescriptionItemDTO>>>(
      path: '/Prescription/detail/readQrCode',
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['barcode'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(PrescriptionItemDTO.fromJson),
    );
  }

  Future<Result<ApiResponse<List<PrescriptionItemDTO>>?>> getDeletedBarcodes({
    int? skip,
    int? take,
    String? search,
  }) async {
    return await fetchRequest<ApiResponse<List<PrescriptionItemDTO>>>(
      path: '/Prescription/detail/QrCodeDelete',
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['barcode'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(PrescriptionItemDTO.fromJson),
    );
  }

  Future<Result<void>> scanBarcode({required int prescriptionItemId, required String qrCode}) {
    return updateRequest<void>(
      path: '/Prescription/detail/$prescriptionItemId/qrCode',
      body: {'prescriptionDetailId ': prescriptionItemId, 'qrCode': qrCode},
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'QR marked as scanned',
    );
  }

  Future<Result<ApiResponse<List<PrescriptionDTO>>?>> getUnappliedPrescriptions({
    int? skip,
    int? take,
    String? search,
  }) async {
    return await fetchRequest<ApiResponse<List<PrescriptionDTO>>>(
      path: _unapplied,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['prescriptionNo'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(PrescriptionDTO.fromJson),
      successLog: 'Unapplied prescriptions fetched',
      emptyLog: 'No unapplied prescriptions',
    );
  }

  Future<Result<List<PrescriptionItemDTO>?>> getUnappliedPrescriptionDetail(int prescriptionId) async {
    return await fetchRequest(
      path: _unappliedDetail(prescriptionId),
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
      successLog: 'Unapplied prescription detail fetched',
      emptyLog: 'No unapplied prescription detail',
    );
  }

  Future<Result<List<PrescriptionDTO>?>> getPatientPrescriptions(int hospitalizationId) async {
    return await fetchRequest(
      path: '$_base/prescription/$hospitalizationId',
      parser: BaseRemoteDataSource.listParser(PrescriptionDTO.fromJson),
      successLog: 'Unapplied prescription detail fetched',
      emptyLog: 'No unapplied prescription detail',
    );
  }

  Future<Result<void>> approvePrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await updateBulkRequest(path: '$_base/detail/$prescriptionId/approveBulk', body: ids);
  }

  Future<Result<void>> cancelPrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await updateBulkRequest(path: '$_base/detail/$prescriptionId/cancelBulk', body: ids);
  }

  Future<Result<void>> rejectPrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await updateBulkRequest(path: '$_base/detail/$prescriptionId/rejectBulk', body: ids);
  }

  Future<Result<void>> updatePrescriptionItem(PrescriptionItemDTO dto) {
    final body = {
      'id': dto.id,
      'prescriptionId': dto.prescriptionId,
      'dosePiece': dto.dosePiece,
      'firstDoseEmergency': dto.firstDoseEmergency,
      'askDoctor': dto.askDoctor,
      'inCaseOfNecessity': dto.inCaseOfNecessity,
      'time': dto.time?.toIso8601String(),
      'description': dto.description,
      'applicationDate': dto.applicationDate?.toIso8601String(),
    };

    return updateRequest(
      path: '$_base/detail/${dto.prescriptionId}',
      body: body,
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Other request created',
    );
  }

  Future<Result<void>> deletePrescription(int prescriptionId) {
    return createRequest<void>(
      path: '$_base/detail/$prescriptionId',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Prescription deleted',
    );
  }

  Future<Result<void>> deleteUnscannedBarcode({required int prescriptionItemId, required String description}) {
    return deleteRequest<void>(
      path: '/Prescription/detail/unreadqrcode/$prescriptionItemId',
      body: {'PrescriptionDetailId': prescriptionItemId, 'DeleteNote': description},
      parser: BaseRemoteDataSource.voidParser(),
      envelope: ResponseEnvelope.raw,
    );
  }

  Future<Result<void>> toggleWarning(int id) {
    return updateRequest(path: '$_base/detail/unReadQrCodeWarning/$id', parser: BaseRemoteDataSource.voidParser());
  }

  Future<Result<List<PrescriptionItemDTO>?>> getMedicineActivities() async {
    return await fetchRequest(
      path: '$_base/detail/materialActivity',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
    );
  }

  Future<Result<List<PrescriptionItemDTO>?>> getEmergencyPatientMedicines(int hospitalizationId) async {
    return await fetchRequest(
      path: '$_base/detail/$hospitalizationId/urgent',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
    );
  }

  Future<Result<List<PrescriptionItemDTO>?>> getDailyJobList() async {
    return await fetchRequest(
      path: '/MyPatient/dailyJobList',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
    );
  }

  Future<Result<List<PrescriptionItemDTO>?>> getPatientPrescriptionHistory(int patientId) async {
    return await fetchRequest(
      path: '$_base/prescriptionByPatientId/$patientId',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
    );
  }
}
