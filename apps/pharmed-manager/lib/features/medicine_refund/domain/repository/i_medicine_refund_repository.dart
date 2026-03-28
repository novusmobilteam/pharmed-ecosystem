import '../../../../core/core.dart';
import '../../../medicine_withdraw/domain/entity/medicine_withdraw_item.dart';
import '../entity/refund.dart';

abstract class IMedicineRefundRepository {
  // Reçete ID'sine göre iade edilebilecekleri getirir
  Future<Result<List<MedicineWithdrawItem>>> getRefundables({required int hospitalizationId});

  // İlgili ilaç için iade durumunu kontrol eder
  Future<Result<MedicineWithdrawItem?>> checkRefundStatus({required int id, required double quantity});

  // İlaç İade İşlemi - İade Kutusuna İade
  Future<Result<void>> refundToBox({required int id, required double quantity});

  // İlaç İade İşlemi - Eczaneye İade
  Future<Result<void>> refundToPharmacy({required int id, required double quantity});

  // İlaç İade İşlemi - Çekmeceye İade
  Future<Result<void>> refundToDrawer({required int id, required double quantity});

  // İlaç İade İşlemi - Çekmeceye İade
  Future<Result<void>> refundToOrigin({
    required int id,
    required double quantity,
    required int cabinDrawerDetailId,
  });

  // Eczaneye iade edilen ilaçları getirir
  Future<Result<List<Refund>>> getPharmacyRefunds();

  // Eczaneye iade edilen ilacın iadesinin tamamlanması işlemi
  Future<Result<void>> completePharmacyRefund(int id);

  // Eczaneye iade edilmiş ve eczacının tamamladığı iadeleri getirir
  Future<Result<List<Refund>>> getCompletedPharmacyRefunds();

  // Çekmeceye iade edilen ilaçları getirir
  Future<Result<List<Refund>>> getDrawerRefunds();

  // İade silme işlemi
  Future<Result<void>> deletePharmacyRefund(int refundId, String? description);
}
