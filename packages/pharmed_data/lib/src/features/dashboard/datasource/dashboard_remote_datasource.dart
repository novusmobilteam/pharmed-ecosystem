import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class DashboardRemoteDataSource extends BaseRemoteDataSource {
  DashboardRemoteDataSource({required super.apiManager});

  final String _basePath = '/Dashboard';

  @override
  String get logSwreq => 'SWREQ-DATA-DASHBOARD-001';

  @override
  String get logUnit => 'SW-UNIT-DASHBOARD';

  Future<Result<List<MenuDTO>?>> getMenus({int? userId}) async {
    final path = userId == null ? '/Menu' : '/Menu/user/$userId';
    return await fetchRequest<List<MenuDTO>>(path: path, parser: BaseRemoteDataSource.listParser(MenuDTO.fromJson));
  }

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

  Future<Result<List<PrescriptionItemDto>?>> getUnappliedPrescriptions() async {
    return await fetchRequest<List<PrescriptionItemDto>>(
      path: '$_basePath/prescriptionCollect',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDto.fromJson),
    );
  }

  Future<Result<List<PrescriptionItemDto>?>> getUnreadQrCodes() async {
    return await fetchRequest<List<PrescriptionItemDto>>(
      path: '$_basePath/unReadQrCode',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDto.fromJson),
    );
  }

  Future<Result<List<PrescriptionItemDto>?>> getUpcomingTreatments({required String mac}) async {
    return await fetchRequest<List<PrescriptionItemDto>>(
      path: '$_basePath/upcomingTreatments',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDto.fromJson),
      query: {"mac": mac},
    );
  }

  Future<Result<List<PrescriptionItemDto>?>> getMissingStocks({required String mac}) async {
    return await fetchRequest<List<PrescriptionItemDto>>(
      path: '$_basePath/mobileStockShortageReported',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDto.fromJson),
      query: {"mac": mac},
    );
  }

  Future<Result<List<CabinDTO>?>> getCabins() async {
    return await fetchRequest<List<CabinDTO>>(
      path: '$_basePath/cabin',
      parser: BaseRemoteDataSource.listParser(CabinDTO.fromJson),
    );
  }

  Future<Result<List<PrescriptionItemMovementDto>?>> getDrugActivities({required String mac}) async {
    return await fetchRequest(
      path: '$_basePath/materialActivity',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemMovementDto.fromJson),
      query: {"mac": mac},
    );
  }
}
