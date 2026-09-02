import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RefundRepositoryImpl implements IRefundRepository {
  RefundRepositoryImpl({
    required RefundRemoteDataSource dataSource,
    required RefundMapper refundMapper,
    required CabinTargetedRxItemMapper withdrawItemMapper,
    required PrescriptionItemMapper prescriptionMapper,
  }) : _dataSource = dataSource,
       _refundMapper = refundMapper,
       _intakeItemMapper = withdrawItemMapper,
       _prescriptionMapper = prescriptionMapper;

  final RefundRemoteDataSource _dataSource;
  final RefundMapper _refundMapper;
  final CabinTargetedRxItemMapper _intakeItemMapper;
  final PrescriptionItemMapper _prescriptionMapper;

  @override
  Future<Result<List<CabinTargetedPrescriptionItem>>> getMasterRefundables({required int hospitalizationId}) async {
    final result = await _dataSource.getMasterRefundables(hospitalizationId: hospitalizationId);
    return result.when(ok: (dtos) => Result.ok(_intakeItemMapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<PrescriptionItem>>> getMobileRefundables({required int hospitalizationId}) async {
    final result = await _dataSource.getMobileRefundables(hospitalizationId: hospitalizationId);
    return result.when(ok: (dtos) => Result.ok(_prescriptionMapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<CabinTargetedPrescriptionItem?>> checkMasterRefundStatus({
    required int id,
    required double quantity,
  }) async {
    final res = await _dataSource.checkMasterRefundStatus(id: id, quantity: quantity);
    return res.when(ok: (dto) => Result.ok(_intakeItemMapper.toEntityOrNull(dto)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> checkMobileRefundStatus({required int id, required double quantity}) async {
    return await _dataSource.checkMobileRefundStatus(id: id, quantity: quantity);
  }

  @override
  Future<Result<void>> refundMobile({required int id, required double quantity}) async {
    return await _dataSource.refundMobile(id: id, quantity: quantity);
  }

  @override
  Future<Result<void>> refundToBox({required int id, required double quantity}) async {
    return await _dataSource.refundToBox(id: id, quantity: quantity);
  }

  @override
  Future<Result<void>> refundToPharmacy({required int id, required double quantity}) async {
    return await _dataSource.refundToPharmacy(id: id, quantity: quantity);
  }

  @override
  Future<Result<void>> refundToDrawer({required int id, required double quantity}) async {
    return await _dataSource.refundToDrawer(id: id, quantity: quantity);
  }

  @override
  Future<Result<void>> refundToOrigin({
    required int id,
    required double quantity,
    required int cabinDrawerDetailId,
  }) async {
    return await _dataSource.refundToOrigin(id: id, quantity: quantity, cabinDrawerDetailId: cabinDrawerDetailId);
  }

  @override
  Future<Result<void>> completePharmacyRefund(int id) async {
    return await _dataSource.completePharmacyRefund(id);
  }

  @override
  Future<Result<ApiResponse<List<Refund>>?>> getDrawerRefunds({
    PagedQueryParams? params,
    required int stationId,
  }) async {
    final result = await _dataSource.getDrawerRefunds(params: params, stationId: stationId);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Refund>>(
          data: apiResponse?.data != null ? _refundMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> deletePharmacyRefund(int refundId, String? description) async {
    return await _dataSource.deletePharmacyRefund(refundId, description);
  }

  @override
  Future<Result<ApiResponse<List<Refund>>?>> getCompletedPharmacyRefunds({
    PagedQueryParams? params,
    required int stationId,
  }) async {
    final result = await _dataSource.getCompletedPharmacyRefunds(params: params, stationId: stationId);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Refund>>(
          data: apiResponse?.data != null ? _refundMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<Refund>>?>> getPharmacyRefunds({
    PagedQueryParams? params,
    required int stationId,
  }) async {
    final result = await _dataSource.getPharmacyRefunds(params: params, stationId: stationId);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Refund>>(
          data: apiResponse?.data != null ? _refundMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }
}
