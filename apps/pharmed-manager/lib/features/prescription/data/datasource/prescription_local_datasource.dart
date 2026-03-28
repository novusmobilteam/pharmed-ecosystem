import '../../../../core/core.dart';
import '../model/prescription_dto.dart';
import '../model/prescription_item_dto.dart';
import '../model/prescription_other_request_dto.dart';
import 'prescription_datasource.dart';

class _PrescriptionStore extends BaseLocalDataSource<PrescriptionDTO, int> {
  _PrescriptionStore({required super.filePath})
      : super(
          fromJson: (m) => PrescriptionDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => d.copyWith(id: id),
        );
}

class _PrescriptionItemStore extends BaseLocalDataSource<PrescriptionItemDTO, int> {
  _PrescriptionItemStore({required super.filePath})
      : super(
          fromJson: (m) => PrescriptionItemDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => d.copyWith(id: id),
        );
}

class _OtherRequestStore extends BaseLocalDataSource<PrescriptionOtherRequestDTO, int> {
  _OtherRequestStore({required super.filePath})
      : super(
          fromJson: (m) => PrescriptionOtherRequestDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.prescriptionId ?? -1,
          assignId: (d, id) => d.copyWith(prescriptionId: id),
        );
}

class PrescriptionLocalDataSource implements PrescriptionDataSource {
  final _PrescriptionItemStore _itemStore;
  final _PrescriptionStore _prescriptionStore;
  final _OtherRequestStore _otherRequestStore;

  PrescriptionLocalDataSource({
    required String prescriptionsPath,
    required String itemsPath,
    required String otherRequestsPath,
  })  : _prescriptionStore = _PrescriptionStore(filePath: prescriptionsPath),
        _itemStore = _PrescriptionItemStore(filePath: itemsPath),
        _otherRequestStore = _OtherRequestStore(filePath: otherRequestsPath);

  @override
  Future<Result<PrescriptionDTO?>> createPrescription(PrescriptionDTO dto) {
    return _prescriptionStore.createRequest(dto);
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getPrescriptionDetail(int registrationId) async {
    final res = await _itemStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createPrescriptionDetail(List<PrescriptionItemDTO> items) async {
    for (final it in items) {
      final r = await _itemStore.createRequest(it);

      final err = r.when(
        ok: (_) => null,
        error: (e) => e,
      );

      if (err != null) {
        return Result.error(err);
      }
    }

    return const Result.ok(null);
  }

  @override
  Future<Result<ApiResponse<List<PrescriptionItemDTO>>>> getUnscannedBarcodes({
    int? skip,
    int? take,
    String? search,
  }) {
    return _itemStore.fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'barcode',
    );
  }

  @override
  Future<Result<ApiResponse<List<PrescriptionItemDTO>>>> getScannedBarcodes({
    int? skip,
    int? take,
    String? search,
  }) {
    return _itemStore.fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'barcode',
    );
  }

  @override
  Future<Result<ApiResponse<List<PrescriptionItemDTO>>>> getDeletedBarcodes({
    int? skip,
    int? take,
    String? search,
  }) {
    return _itemStore.fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'barcode',
    );
  }

  @override
  Future<Result<void>> scanBarcode({required int prescriptionItemId, required String qrCode}) async {
    final res = await _itemStore.fetchRequest();
    return res.when(
      ok: (_) => Result.ok(null),
      error: (error) => Result.error(error),
    );
  }

  @override
  Future<Result<ApiResponse<List<PrescriptionDTO>>>> getUnappliedPrescriptions({
    int? skip,
    int? take,
    String? search,
  }) {
    return _prescriptionStore.fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'prescriptionNo',
    );
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getUnappliedPrescriptionDetail(int prescriptionId) async {
    final res = await _itemStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<PrescriptionOtherRequestDTO?>> createOtherRequest(PrescriptionOtherRequestDTO dto) async {
    return _otherRequestStore.createRequest(dto);
  }

  @override
  Future<Result<List<PrescriptionDTO>>> getPatientPrescriptions(int patientId) async {
    final res = await _prescriptionStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> approvePrescriptionRequests(int prescriptionId, List<int> ids) async {
    await Future.delayed(Duration(milliseconds: 500));
    return Result.ok(null);
  }

  @override
  Future<Result<void>> cancelPrescriptionRequests(int prescriptionId, List<int> ids) async {
    await Future.delayed(Duration(milliseconds: 500));
    return Result.ok(null);
  }

  @override
  Future<Result<void>> rejectPrescriptionRequests(int prescriptionId, List<int> ids) async {
    await Future.delayed(Duration(milliseconds: 500));
    return Result.ok(null);
  }

  @override
  Future<Result<void>> updatePrescriptionItem(PrescriptionItemDTO dto) async {
    await Future.delayed(Duration(milliseconds: 500));
    return Result.ok(null);
  }

  @override
  Future<Result<void>> deletePrescription(int prescriptionId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return Result.ok(null);
  }

  @override
  Future<Result<void>> deleteUnscannedBarcode({required int prescriptionItemId, required String description}) async {
    await Future.delayed(Duration(milliseconds: 500));
    return Result.ok(null);
  }

  @override
  Future<Result<void>> toggleWarning(int prescriptionId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return Result.ok(null);
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getMedicineActivities() async {
    final res = await _itemStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getEmergencyPatientMedicines(int hospitalizationId) async {
    final res = await _itemStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getDailyJobList() async {
    final res = await _itemStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getPatientPrescriptionHistory(int patientId) async {
    final res = await _itemStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }
}
