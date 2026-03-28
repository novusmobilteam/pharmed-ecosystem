import '../../../../core/core.dart';
import '../../../medicine_withdraw/data/model/medicine_withdraw_item_dto.dart';
import '../model/refund_dto.dart';

abstract class MedicineRefundDataSource {
  // Reçete ID'sine göre iade edilebilecekleri getirir
  Future<Result<List<MedicineWithdrawItemDTO>>> getRefundables({required int hospitalizationId});

  // İlgili ilaç için iade durumunu kontrol eder
  Future<Result<MedicineWithdrawItemDTO?>> checkRefundStatus({required int id, required double quantity});

  // İlaç İade İşlemi - İade Kutusuna İade
  Future<Result<void>> refundToBox({required int id, required double quantity});

  // İlaç İade İşlemi - Eczaneye İade
  Future<Result<void>> refundToPharmacy({required int id, required double quantity});

  // İlaç İade İşlemi - Çekmeceye İade
  Future<Result<void>> refundToDrawer({required int id, required double quantity});

  // İlaç İade İşlemi - Yerine İade
  Future<Result<void>> refundToOrigin({
    required int id,
    required double quantity,
    required int cabinDrawerDetailId,
  });

  // Eczaneye iade edilen ilaçları getirir
  Future<Result<List<RefundDTO>>> getPharmacyRefunds();

  // Eczaneye iade edilen ilacın iadesinin tamamlanması işlemi
  Future<Result<void>> completePharmacyRefund(int id);

  // Eczaneye iade edilmiş ve eczacının tamamladığı iadeleri getirir
  Future<Result<List<RefundDTO>>> getCompletedPharmacyRefunds();

  // Çekmeceye iade edilen ilaçları getirir
  Future<Result<List<RefundDTO>>> getDrawerRefunds();

  // İade silme işlemi
  Future<Result<void>> deletePharmacyRefund(int refundId, String? description);
}
