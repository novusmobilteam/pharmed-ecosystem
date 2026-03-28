import '../../../../core/core.dart';
import '../../../cabin_stock/data/model/cabin_stock_dto.dart';
import '../../../medicine_refund/data/model/refund_dto.dart';
import '../../../prescription/data/model/prescription_dto.dart';
import '../../../prescription/data/model/prescription_item_dto.dart';

abstract class DashboardDataSource {
  Future<Result<List<PrescriptionItemDTO>>> getUnreadQrCodes();
  Future<Result<List<CabinStockDTO>>> getExpiringMaterials();
  Future<Result<List<CabinStockDTO>>> getCriticalStocks({bool isClient = false});
  Future<Result<List<PrescriptionDTO>>> getUnappliedPrescriptions();
  Future<Result<List<RefundDTO>>> getRefunds();
  Future<Result<List<CabinStockDTO>>> getGeneralStocks();
  Future<Result<List<PrescriptionItemDTO>>> getUpcomingTreatments();
}
