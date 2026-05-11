import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RefundRemoteDataSource extends BaseRemoteDataSource {
  RefundRemoteDataSource({required super.apiManager});

  @override
  String get logSwreq => 'SWREQ-DATA-REFUND-001';

  @override
  String get logUnit => 'SW-UNIT-REFUND';

  Future<Result<List<MedicineIntakeItemDto>>> getRefundables({required int hospitalizationId}) async {
    final res = await fetchRequest<List<MedicineIntakeItemDto>>(
      path: '/Prescription/detail/getReturn/$hospitalizationId',
      parser: BaseRemoteDataSource.listParser(MedicineIntakeItemDto.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <MedicineIntakeItemDto>[]), error: Result.error);
  }

  Future<Result<MedicineIntakeItemDto?>> checkRefundStatus({required int id, required double quantity}) async {
    final res = await postRequest(
      path: '/Prescription/detail/$id/refundControl',
      parser: (json) {
        final detail = (json as Map<String, dynamic>)['detail'];
        return detail != null ? MedicineIntakeItemDto.fromJson(detail) : null;
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

  Future<Result<void>> refundToBox({required int id, required double quantity}) async {
    return await postRequest(
      path: '/Prescription/detail/$id/refundReturnBox',
      parser: BaseRemoteDataSource.voidParser(),
      query: {'id': id, 'quantity': quantity},
    );
  }

  Future<Result<void>> refundToPharmacy({required int id, required double quantity}) async {
    return await postRequest(
      path: '/Prescription/detail/$id/refundPharmacy',
      parser: BaseRemoteDataSource.voidParser(),
      query: {'id': id, 'quantity': quantity},
    );
  }

  Future<Result<void>> refundToOrigin({
    required int id,
    required double quantity,
    required int cabinDrawerDetailId,
  }) async {
    return await postRequest(
      path: '/Prescription/detail/$id/refundInstead', // instead :D
      parser: BaseRemoteDataSource.voidParser(),
      query: {'id': id, 'quantity': quantity, 'cabinDrawrDetailId': cabinDrawerDetailId},
    );
  }

  Future<Result<void>> refundToDrawer({required int id, required double quantity}) async {
    return await postRequest(
      path: '/Prescription/detail/$id/refundDrawr',
      parser: BaseRemoteDataSource.voidParser(),
      query: {'id': id, 'quantity': quantity},
    );
  }

  Future<Result<List<RefundDTO>?>> getPharmacyRefunds() async {
    return await fetchRequest(
      path: '/RefundWasteDescrutionTransaction/refundApprovedPharmacy',
      parser: BaseRemoteDataSource.listParser(RefundDTO.fromJson),
    );
  }

  Future<Result<void>> completePharmacyRefund(int id) async {
    return await postRequest(
      path: '/RefundWasteDescrutionTransaction/approve/$id',
      parser: BaseRemoteDataSource.voidParser(),
    );
  }

  Future<Result<List<RefundDTO>?>> getCompletedPharmacyRefunds() async {
    return await fetchRequest(
      path: '/RefundWasteDescrutionTransaction/refundApprovelPharmacy',
      parser: BaseRemoteDataSource.listParser(RefundDTO.fromJson),
    );
  }

  Future<Result<List<RefundDTO>?>> getDrawerRefunds() async {
    return await fetchRequest(
      path: '/RefundWasteDescrutionTransaction/refundDrawr',
      parser: BaseRemoteDataSource.listParser(RefundDTO.fromJson),
    );
  }

  Future<Result<void>> deletePharmacyRefund(int refundId, String? description) {
    return postRequest(
      path: '/RefundWasteDescrutionTransaction/delete',
      parser: BaseRemoteDataSource.voidParser(),
      body: {'refundWasteDescrutionTransactionId': refundId, 'deleteNote': description},
      successLog: 'Refund deleted',
    );
  }
}
