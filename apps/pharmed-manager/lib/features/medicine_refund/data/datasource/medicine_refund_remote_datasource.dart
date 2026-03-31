import '../../../../core/core.dart';
import '../../../medicine_withdraw/data/model/medicine_withdraw_item_dto.dart';
import '../model/refund_dto.dart';
import 'medicine_refund_datasource.dart';

class MedicineRefundRemoteDataSource extends BaseRemoteDataSource implements MedicineRefundDataSource {
  MedicineRefundRemoteDataSource({required super.apiManager});

  @override
  Future<Result<List<MedicineWithdrawItemDTO>>> getRefundables({required int hospitalizationId}) async {
    final res = await fetchRequest<List<MedicineWithdrawItemDTO>>(
      path: '/Prescription/detail/getReturn/$hospitalizationId',
      parser: BaseRemoteDataSource.listParser(MedicineWithdrawItemDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <MedicineWithdrawItemDTO>[]), error: Result.error);
  }

  @override
  Future<Result<MedicineWithdrawItemDTO?>> checkRefundStatus({required int id, required double quantity}) async {
    final res = await createRequest(
      path: '/Prescription/detail/$id/refundControl',
      parser: (json) {
        final detail = (json as Map<String, dynamic>)['detail'];
        return detail != null ? MedicineWithdrawItemDTO.fromJson(detail) : null;
      },
      query: {'id': id, 'quantity': quantity},
    );
    return res.when(
      ok: (data) {
        print('Inside DataSource: ${data?.toJson().toString()}');
        return Result.ok(data);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> refundToBox({required int id, required double quantity}) async {
    final res = await createRequest(
      path: '/Prescription/detail/$id/refundReturnBox',
      parser: BaseRemoteDataSource.voidParser(),
      query: {'id': id, 'quantity': quantity},
    );
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<void>> refundToPharmacy({required int id, required double quantity}) async {
    final res = await createRequest(
      path: '/Prescription/detail/$id/refundPharmacy',
      parser: BaseRemoteDataSource.voidParser(),
      query: {'id': id, 'quantity': quantity},
    );
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<void>> refundToOrigin({
    required int id,
    required double quantity,
    required int cabinDrawerDetailId,
  }) async {
    final res = await createRequest(
      path: '/Prescription/detail/$id/refundInstead', // instead :D
      parser: BaseRemoteDataSource.voidParser(),
      query: {'id': id, 'quantity': quantity, 'cabinDrawrDetailId': cabinDrawerDetailId},
    );
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<void>> refundToDrawer({required int id, required double quantity}) async {
    final res = await createRequest(
      path: '/Prescription/detail/$id/refundDrawr',
      parser: BaseRemoteDataSource.voidParser(),
      query: {'id': id, 'quantity': quantity},
    );
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<List<RefundDTO>>> getPharmacyRefunds() async {
    final res = await fetchRequest<List<RefundDTO>>(
      path: '/RefundWasteDescrutionTransaction/refundApprovedPharmacy',
      parser: BaseRemoteDataSource.listParser(RefundDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <RefundDTO>[]), error: Result.error);
  }

  @override
  Future<Result<void>> completePharmacyRefund(int id) async {
    final res = await createRequest(
      path: '/RefundWasteDescrutionTransaction/approve/$id',
      parser: BaseRemoteDataSource.voidParser(),
    );
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<List<RefundDTO>>> getCompletedPharmacyRefunds() async {
    final res = await fetchRequest<List<RefundDTO>>(
      path: '/RefundWasteDescrutionTransaction/refundApprovelPharmacy',
      parser: BaseRemoteDataSource.listParser(RefundDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <RefundDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<RefundDTO>>> getDrawerRefunds() async {
    final res = await fetchRequest<List<RefundDTO>>(
      path: '/RefundWasteDescrutionTransaction/refundDrawr',
      parser: BaseRemoteDataSource.listParser(RefundDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <RefundDTO>[]), error: Result.error);
  }

  @override
  Future<Result<void>> deletePharmacyRefund(int refundId, String? description) {
    return createRequest(
      path: '/RefundWasteDescrutionTransaction/delete',
      parser: BaseRemoteDataSource.voidParser(),
      body: {'refundWasteDescrutionTransactionId': refundId, 'deleteNote': description},
      successLog: 'Refund deleted',
    );
  }

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();
}
