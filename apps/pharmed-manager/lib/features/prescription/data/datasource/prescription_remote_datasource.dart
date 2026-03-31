import '../../../../core/core.dart';
import '../model/prescription_dto.dart';
import '../model/prescription_item_dto.dart';
import '../model/prescription_other_request_dto.dart';
import 'prescription_datasource.dart';

class PrescriptionRemoteDataSource extends BaseRemoteDataSource implements PrescriptionDataSource {
  PrescriptionRemoteDataSource({required super.apiManager});

  static const String _base = '/Prescription';
  static const String _detail = '/Prescription/detail/bulk';
  static const String _unapplied = '$_base/uncollectedPrescriptionMaster';
  static const String _other = '/Prescription/otherRequest';

  static String _unappliedDetail(int id) => '/Prescription/uncollectedPrescriptionDetail/$id';

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();

  @override
  Future<Result<PrescriptionDTO?>> createPrescription(PrescriptionDTO dto) {
    return createRequest<PrescriptionDTO?>(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(PrescriptionDTO.fromJson),
      successLog: 'Prescription created',
      envelope: ResponseEnvelope.apiResponse,
    );
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getPrescriptionDetail(int prescriptionId) {
    return fetchRequest<List<PrescriptionItemDTO>>(
      path: '$_base/detail/$prescriptionId/getAll',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
      successLog: 'Prescription items fetched',
      emptyLog: 'No prescription items',
    ).then((res) => res.when(ok: (data) => Result.ok(data ?? const <PrescriptionItemDTO>[]), error: Result.error));
  }

  @override
  Future<Result<void>> createPrescriptionDetail(List<PrescriptionItemDTO> items) {
    final body = {'prescriptionDetails': items.map((e) => e.toJson()).toList()};

    return createRequest<void>(
      path: _detail,
      body: body,
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Prescription items created',
    );
  }

  @override
  Future<Result<ApiResponse<List<PrescriptionItemDTO>>>> getUnscannedBarcodes({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<PrescriptionItemDTO>>>(
      path: '/Prescription/detail/unReadQrCode',
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['barcode'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(PrescriptionItemDTO.fromJson),
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: (error) => Result.error(error),
    );
  }

  @override
  Future<Result<ApiResponse<List<PrescriptionItemDTO>>>> getScannedBarcodes({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<PrescriptionItemDTO>>>(
      path: '/Prescription/detail/readQrCode',
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['barcode'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(PrescriptionItemDTO.fromJson),
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: (error) => Result.error(error),
    );
  }

  @override
  Future<Result<ApiResponse<List<PrescriptionItemDTO>>>> getDeletedBarcodes({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<PrescriptionItemDTO>>>(
      path: '/Prescription/detail/QrCodeDelete',
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['barcode'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(PrescriptionItemDTO.fromJson),
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: (error) => Result.error(error),
    );
  }

  @override
  Future<Result<void>> scanBarcode({required int prescriptionItemId, required String qrCode}) {
    return updateRequest<void>(
      path: '/Prescription/detail/$prescriptionItemId/qrCode',
      body: {'prescriptionDetailId ': prescriptionItemId, 'qrCode': qrCode},
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'QR marked as scanned',
    );
  }

  @override
  Future<Result<ApiResponse<List<PrescriptionDTO>>>> getUnappliedPrescriptions({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<PrescriptionDTO>>>(
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

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getUnappliedPrescriptionDetail(int prescriptionId) async {
    final res = await fetchRequest<List<PrescriptionItemDTO>>(
      path: _unappliedDetail(prescriptionId),
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
      successLog: 'Unapplied prescription detail fetched',
      emptyLog: 'No unapplied prescription detail',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <PrescriptionItemDTO>[]), error: Result.error);
  }

  @override
  Future<Result<PrescriptionOtherRequestDTO?>> createOtherRequest(PrescriptionOtherRequestDTO dto) {
    return createRequest<PrescriptionOtherRequestDTO?>(
      path: _other,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(PrescriptionOtherRequestDTO.fromJson),
      successLog: 'Other request created',
    );
  }

  @override
  Future<Result<List<PrescriptionDTO>>> getPatientPrescriptions(int hospitalizationId) async {
    final res = await fetchRequest<List<PrescriptionDTO>>(
      path: '$_base/prescription/$hospitalizationId',
      parser: BaseRemoteDataSource.listParser(PrescriptionDTO.fromJson),
      successLog: 'Unapplied prescription detail fetched',
      emptyLog: 'No unapplied prescription detail',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <PrescriptionDTO>[]), error: Result.error);
  }

  @override
  Future<Result<void>> approvePrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await updateBulkRequest(path: '$_base/detail/$prescriptionId/approveBulk', body: ids);
  }

  @override
  Future<Result<void>> cancelPrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await updateBulkRequest(path: '$_base/detail/$prescriptionId/cancelBulk', body: ids);
  }

  @override
  Future<Result<void>> rejectPrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await updateBulkRequest(path: '$_base/detail/$prescriptionId/rejectBulk', body: ids);
  }

  @override
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

  @override
  Future<Result<void>> deletePrescription(int prescriptionId) {
    return createRequest<void>(
      path: '$_base/detail/$prescriptionId',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Prescription deleted',
    );
  }

  @override
  Future<Result<void>> deleteUnscannedBarcode({required int prescriptionItemId, required String description}) {
    return deleteRequest<void>(
      path: '/Prescription/detail/unreadqrcode/$prescriptionItemId',
      body: {'PrescriptionDetailId': prescriptionItemId, 'DeleteNote': description},
      parser: BaseRemoteDataSource.voidParser(),
      envelope: ResponseEnvelope.raw,
    );
  }

  @override
  Future<Result<void>> toggleWarning(int id) {
    return updateRequest(path: '$_base/detail/unReadQrCodeWarning/$id', parser: BaseRemoteDataSource.voidParser());
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getMedicineActivities() async {
    final res = await fetchRequest<List<PrescriptionItemDTO>>(
      path: '$_base/detail/materialActivity',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <PrescriptionItemDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getEmergencyPatientMedicines(int hospitalizationId) async {
    final res = await fetchRequest<List<PrescriptionItemDTO>>(
      path: '$_base/detail/$hospitalizationId/urgent',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <PrescriptionItemDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getDailyJobList() async {
    final res = await fetchRequest<List<PrescriptionItemDTO>>(
      path: '/MyPatient/dailyJobList',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <PrescriptionItemDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getPatientPrescriptionHistory(int patientId) async {
    final res = await fetchRequest<List<PrescriptionItemDTO>>(
      path: '$_base/prescriptionByPatientId/$patientId',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <PrescriptionItemDTO>[]), error: Result.error);
  }
}
