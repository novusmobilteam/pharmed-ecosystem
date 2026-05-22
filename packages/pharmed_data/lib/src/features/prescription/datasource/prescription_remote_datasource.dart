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

  Future<Result<PrescriptionDto?>> createPrescription(PrescriptionDto dto) {
    return postRequest<PrescriptionDto?>(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(PrescriptionDto.fromJson),
      successLog: 'Prescription created',
      envelope: ResponseEnvelope.apiResponse,
    );
  }

  Future<Result<List<PrescriptionItemDto>?>> getPrescriptionDetail(int prescriptionId) {
    return fetchRequest<List<PrescriptionItemDto>>(
      path: '$_base/detail/$prescriptionId/getAll',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDto.fromJson),
      successLog: 'Prescription items fetched',
      emptyLog: 'No prescription items',
    );
  }

  Future<Result<void>> createPrescriptionDetail(List<PrescriptionItemDto> items) {
    final body = {'prescriptionDetails': items.map((e) => e.toJson()).toList()};

    return postRequest<void>(
      path: _detail,
      body: body,
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Prescription items created',
    );
  }

  Future<Result<ApiResponse<List<PrescriptionItemDto>>?>> getUnscannedBarcodes({
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
      parser: BaseRemoteDataSource.apiResponseListParser(PrescriptionItemDto.fromJson),
    );
  }

  Future<Result<ApiResponse<List<PrescriptionItemDto>>?>> getScannedBarcodes({
    int? skip,
    int? take,
    String? search,
  }) async {
    return await fetchRequest<ApiResponse<List<PrescriptionItemDto>>>(
      path: '/Prescription/detail/readQrCode',
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['barcode'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(PrescriptionItemDto.fromJson),
    );
  }

  Future<Result<ApiResponse<List<PrescriptionItemDto>>?>> getDeletedBarcodes({
    int? skip,
    int? take,
    String? search,
  }) async {
    return await fetchRequest<ApiResponse<List<PrescriptionItemDto>>>(
      path: '/Prescription/detail/QrCodeDelete',
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['barcode'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(PrescriptionItemDto.fromJson),
    );
  }

  Future<Result<void>> scanBarcode({required int prescriptionItemId, required String qrCode}) {
    return putRequest<void>(
      path: '/Prescription/detail/$prescriptionItemId/qrCode',
      body: {'prescriptionDetailId ': prescriptionItemId, 'qrCode': qrCode},
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'QR marked as scanned',
    );
  }

  Future<Result<ApiResponse<List<PrescriptionDto>>?>> getUnappliedPrescriptions({
    int? skip,
    int? take,
    String? search,
  }) async {
    return await fetchRequest<ApiResponse<List<PrescriptionDto>>>(
      path: _unapplied,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['prescriptionNo'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(PrescriptionDto.fromJson),
      successLog: 'Unapplied prescriptions fetched',
      emptyLog: 'No unapplied prescriptions',
    );
  }

  Future<Result<List<PrescriptionItemDto>?>> getUnappliedPrescriptionDetail(int prescriptionId) async {
    return await fetchRequest(
      path: _unappliedDetail(prescriptionId),
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDto.fromJson),
      successLog: 'Unapplied prescription detail fetched',
      emptyLog: 'No unapplied prescription detail',
    );
  }

  Future<Result<List<PrescriptionDto>?>> getPatientPrescriptions(int hospitalizationId) async {
    return await fetchRequest(
      path: '$_base/prescription/$hospitalizationId',
      parser: BaseRemoteDataSource.listParser(PrescriptionDto.fromJson),
      successLog: 'Unapplied prescription detail fetched',
      emptyLog: 'No unapplied prescription detail',
    );
  }

  Future<Result<void>> checkPrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await putBulkRequest(path: '$_base/detail/$prescriptionId/approveBulkCheck', body: ids);
  }

  Future<Result<void>> approvePrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await putBulkRequest(path: '$_base/detail/$prescriptionId/approveBulk', body: ids);
  }

  Future<Result<void>> cancelPrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await putBulkRequest(path: '$_base/detail/$prescriptionId/cancelBulk', body: ids);
  }

  Future<Result<void>> rejectPrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await putBulkRequest(path: '$_base/detail/$prescriptionId/rejectBulk', body: ids);
  }

  Future<Result<void>> updatePrescriptionItem(PrescriptionItemDto dto) {
    final body = {
      'id': dto.id,
      'prescriptionId': dto.prescriptionId,
      'dosePiece': dto.dosePiece,
      'firstDoseEmergency': dto.firstDoseEmergency,
      'askDoctor': dto.askDoctor,
      'inCaseOfNecessity': dto.inCaseOfNecessity,
      'time': dto.time?.toIso8601String(),
      'description': dto.description,
    };

    return putRequest(
      path: '$_base/detail/${dto.prescriptionId}',
      body: body,
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Other request created',
    );
  }

  Future<Result<void>> deletePrescription(int prescriptionId) {
    return postRequest<void>(
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
    return putRequest(path: '$_base/detail/unReadQrCodeWarning/$id', parser: BaseRemoteDataSource.voidParser());
  }

  Future<Result<List<PrescriptionItemDto>?>> getDrugActivity() async {
    return await fetchRequest(
      path: '$_base/detail/materialActivity',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDto.fromJson),
    );
  }

  Future<Result<ApiResponse<List<PrescriptionItemMovementDto>>?>> getCurrentStationDrugActivity({
    int? skip,
    int? take,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await fetchRequest(
      path: '$_base/detail/materialActivityCurrentStation',
      skip: skip,
      take: take,
      startDate: startDate,
      endDate: endDate,
      parser: BaseRemoteDataSource.apiResponseListParser(PrescriptionItemMovementDto.fromJson),
    );
  }

  Future<Result<List<PrescriptionItemDto>?>> getEmergencyPatientMedicines(int hospitalizationId) async {
    return await fetchRequest(
      path: '$_base/detail/$hospitalizationId/urgent',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDto.fromJson),
    );
  }

  Future<Result<List<PrescriptionItemDto>?>> getDailyJobList() async {
    return await fetchRequest(
      path: '/MyPatient/dailyJobList',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDto.fromJson),
    );
  }

  Future<Result<List<PrescriptionItemDto>?>> getPatientPrescriptionHistory(int patientId) async {
    return await fetchRequest(
      path: '$_base/prescriptionByPatientId/$patientId',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDto.fromJson),
    );
  }

  Future<Result<void>> assignRfidTag({required int prescriptionItemId, required String epc}) async {
    final path = '$_base/detail/$prescriptionItemId/rfidCardTag/$epc';
    return await putRequest(path: path, parser: BaseRemoteDataSource.voidParser());
  }

  Future<Result<void>> deleteRfidTag({required int prescriptionItemId}) async {
    final path = '$_base/detail/$prescriptionItemId/rfidCardTag';
    return await deleteRequest(path: path, parser: BaseRemoteDataSource.voidParser());
  }

  Future<Result<List<PrescriptionItemMovementDto>?>> getPrescriptionItemMovements(int prescriptionItemId) async {
    return await fetchRequest(
      path: '$_base/detail/history/$prescriptionItemId',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemMovementDto.fromJson),
    );
  }
}
