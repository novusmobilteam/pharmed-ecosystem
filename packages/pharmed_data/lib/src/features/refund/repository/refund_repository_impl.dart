import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RefundRepositoryImpl implements IRefundRepository {
  RefundRepositoryImpl({
    required RefundRemoteDataSource dataSource,
    required RefundMapper refundMapper,
    required MedicineWithdrawItemMapper withdrawItemMapper,
  }) : _dataSource = dataSource,
       _refundMapper = refundMapper,
       _withdrawItemMapper = withdrawItemMapper;

  final RefundRemoteDataSource _dataSource;
  final RefundMapper _refundMapper;
  final MedicineWithdrawItemMapper _withdrawItemMapper;

  @override
  Future<Result<List<MedicineWithdrawItem>>> getRefundables({required int hospitalizationId}) async {
    final result = await _dataSource.getRefundables(hospitalizationId: hospitalizationId);
    return result.when(ok: (dtos) => Result.ok(_withdrawItemMapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<MedicineWithdrawItem?>> checkRefundStatus({required int id, required double quantity}) async {
    final res = await _dataSource.checkRefundStatus(id: id, quantity: quantity);
    return res.when(ok: (dto) => Result.ok(_withdrawItemMapper.toEntityOrNull(dto)), error: (e) => Result.error(e));
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
  Future<Result<List<Refund>>> getCompletedPharmacyRefunds() async {
    final result = await _dataSource.getCompletedPharmacyRefunds();
    return result.when(ok: (dtos) => Result.ok(_refundMapper.toEntityList(dtos ?? [])), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<Refund>>> getPharmacyRefunds() async {
    final result = await _dataSource.getPharmacyRefunds();
    return result.when(ok: (dtos) => Result.ok(_refundMapper.toEntityList(dtos ?? [])), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<Refund>>> getDrawerRefunds() async {
    final result = await _dataSource.getDrawerRefunds();
    return result.when(ok: (dtos) => Result.ok(_refundMapper.toEntityList(dtos ?? [])), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deletePharmacyRefund(int refundId, String? description) async {
    return await _dataSource.deletePharmacyRefund(refundId, description);
  }
}
