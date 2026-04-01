import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class DashboardRemoteDataSource extends BaseRemoteDataSource {
  DashboardRemoteDataSource({required super.apiManager});

  final String _basePath = '/Dashboard';

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();

  Future<Result<List<CabinStockDTO>?>> getCriticalStocks({bool isClient = false}) async {
    Map<String, dynamic>? query = isClient ? {"mac": DeviceInfo.getMacAddress()} : null;
    final path = isClient ? "clientCriticalStock" : "criticalStock";

    return await fetchRequest<List<CabinStockDTO>>(
      path: '$_basePath/$path',
      parser: BaseRemoteDataSource.listParser(CabinStockDTO.fromJson),
      query: query,
    );
  }

  Future<Result<List<CabinStockDTO>?>> getExpiringMaterials() async {
    return await fetchRequest<List<CabinStockDTO>>(
      path: '$_basePath/miadDate',
      parser: BaseRemoteDataSource.listParser(CabinStockDTO.fromJson),
    );
  }

  Future<Result<List<CabinStockDTO>?>> getGeneralStocks() async {
    return await fetchRequest<List<CabinStockDTO>>(
      path: '$_basePath/generalStock',
      parser: BaseRemoteDataSource.listParser(CabinStockDTO.fromJson),
    );
  }

  Future<Result<List<RefundDTO>?>> getRefunds() async {
    return await fetchRequest<List<RefundDTO>>(
      path: '$_basePath/refundPharmacy',
      parser: BaseRemoteDataSource.listParser(RefundDTO.fromJson),
    );
  }

  Future<Result<List<PrescriptionDTO>?>> getUnappliedPrescriptions() async {
    return await fetchRequest<List<PrescriptionDTO>>(
      path: '$_basePath/prescriptionCollect',
      parser: BaseRemoteDataSource.listParser(PrescriptionDTO.fromJson),
    );
  }

  Future<Result<List<PrescriptionItemDTO>?>> getUnreadQrCodes() async {
    return await fetchRequest<List<PrescriptionItemDTO>>(
      path: '$_basePath/unReadQrCode',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
    );
  }

  Future<Result<List<PrescriptionItemDTO>?>> getUpcomingTreatments() async {
    return await fetchRequest<List<PrescriptionItemDTO>>(
      path: '$_basePath/clientPrescriptionCollect',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
      query: {"mac": DeviceInfo.getMacAddress()},
    );
  }
}
