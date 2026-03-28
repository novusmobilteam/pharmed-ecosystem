import '../../../../core/core.dart';
import '../../../cabin_stock/domain/entity/cabin_stock.dart';
import '../../../medicine_refund/domain/entity/refund.dart';
import '../../../prescription/domain/entity/prescription.dart';
import '../../../prescription/domain/entity/prescription_item.dart';

abstract class IDashboardRepository {
  Future<Result<List<PrescriptionItem>>> getUnreadQrCodes();
  Future<Result<List<CabinStock>>> getExpiringMaterials();
  Future<Result<List<CabinStock>>> getCriticalStocks({bool isClient = false});
  Future<Result<List<Prescription>>> getUnappliedPrescriptions();
  Future<Result<List<Refund>>> getRefunds();
  Future<Result<List<CabinStock>>> getGeneralStocks();
  Future<Result<List<PrescriptionItem>>> getUpcomingTreatments();
}
