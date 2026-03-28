import '../../../../core/core.dart';

import '../../../medicine_withdraw/domain/entity/medicine_withdraw_item.dart';
import '../../domain/entity/refund.dart';

import '../../domain/repository/i_medicine_refund_repository.dart';
import '../datasource/medicine_refund_datasource.dart';

class MedicineRefundRepository implements IMedicineRefundRepository {
  final MedicineRefundDataSource _ds;

  MedicineRefundRepository(this._ds);

  @override
  Future<Result<List<MedicineWithdrawItem>>> getRefundables({required int hospitalizationId}) async {
    final res = await _ds.getRefundables(hospitalizationId: hospitalizationId);
    return res.when(
      ok: (list) {
        final entities = list.map((d) => d.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<MedicineWithdrawItem?>> checkRefundStatus({required int id, required double quantity}) async {
    final res = await _ds.checkRefundStatus(id: id, quantity: quantity);
    return res.when(
      ok: (data) {
        return Result.ok(data?.toEntity());
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<void>> refundToBox({required int id, required double quantity}) async {
    return await _ds.refundToBox(id: id, quantity: quantity);
  }

  @override
  Future<Result<void>> refundToPharmacy({required int id, required double quantity}) async {
    return await _ds.refundToPharmacy(id: id, quantity: quantity);
  }

  @override
  Future<Result<void>> refundToDrawer({required int id, required double quantity}) async {
    return await _ds.refundToDrawer(id: id, quantity: quantity);
  }

  @override
  Future<Result<void>> refundToOrigin({
    required int id,
    required double quantity,
    required int cabinDrawerDetailId,
  }) async {
    return await _ds.refundToOrigin(id: id, quantity: quantity, cabinDrawerDetailId: cabinDrawerDetailId);
  }

  @override
  Future<Result<void>> completePharmacyRefund(int id) async {
    return await _ds.completePharmacyRefund(id);
  }

  @override
  Future<Result<List<Refund>>> getCompletedPharmacyRefunds() async {
    final res = await _ds.getCompletedPharmacyRefunds();
    return res.when(
      ok: (list) {
        final entities = list.map((d) => d.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<List<Refund>>> getPharmacyRefunds() async {
    final res = await _ds.getPharmacyRefunds();
    return res.when(
      ok: (list) {
        final entities = list.map((d) => d.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<List<Refund>>> getDrawerRefunds() async {
    final res = await _ds.getDrawerRefunds();
    return res.when(
      ok: (list) {
        final entities = list.map((d) => d.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<void>> deletePharmacyRefund(int refundId, String? description) async {
    return await _ds.deletePharmacyRefund(refundId, description);
  }
}
