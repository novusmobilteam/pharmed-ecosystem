import '../../../../core/utils/device_info.dart';

import '../../../../core/core.dart';
import '../../../medicine_refund/data/model/refund_dto.dart';
import '../../../prescription/data/model/prescription_dto.dart';
import '../../../prescription/data/model/prescription_item_dto.dart';
import 'dashboard_datasource.dart';

class DashboardRemoteDataSource extends BaseRemoteDataSource implements DashboardDataSource {
  DashboardRemoteDataSource({required super.apiManager});

  final String _basePath = '/Dashboard';

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();

  @override
  Future<Result<List<CabinStockDTO>>> getCriticalStocks({bool isClient = false}) async {
    Map<String, dynamic>? query = isClient ? {"mac": DeviceInfo.getMacAddress()} : null;
    final path = isClient ? "clientCriticalStock" : "criticalStock";
    final res = await fetchRequest<List<CabinStockDTO>>(
      path: '$_basePath/$path',
      parser: BaseRemoteDataSource.listParser(CabinStockDTO.fromJson),
      query: query,
    );

    return res.when(ok: (data) => Result.ok(data ?? const <CabinStockDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<CabinStockDTO>>> getExpiringMaterials() async {
    final res = await fetchRequest<List<CabinStockDTO>>(
      path: '$_basePath/miadDate',
      parser: BaseRemoteDataSource.listParser(CabinStockDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <CabinStockDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<CabinStockDTO>>> getGeneralStocks() async {
    final res = await fetchRequest<List<CabinStockDTO>>(
      path: '$_basePath/generalStock',
      parser: BaseRemoteDataSource.listParser(CabinStockDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <CabinStockDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<RefundDTO>>> getRefunds() async {
    final res = await fetchRequest<List<RefundDTO>>(
      path: '$_basePath/refundPharmacy',
      parser: BaseRemoteDataSource.listParser(RefundDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <RefundDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<PrescriptionDTO>>> getUnappliedPrescriptions() async {
    final res = await fetchRequest<List<PrescriptionDTO>>(
      path: '$_basePath/prescriptionCollect',
      parser: BaseRemoteDataSource.listParser(PrescriptionDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <PrescriptionDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getUnreadQrCodes() async {
    final res = await fetchRequest<List<PrescriptionItemDTO>>(
      path: '$_basePath/unReadQrCode',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? const <PrescriptionItemDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getUpcomingTreatments() async {
    final res = await fetchRequest<List<PrescriptionItemDTO>>(
      path: '$_basePath/clientPrescriptionCollect',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
      query: {"mac": DeviceInfo.getMacAddress()},
    );

    return res.when(ok: (data) => Result.ok(data ?? const <PrescriptionItemDTO>[]), error: Result.error);
  }
}
