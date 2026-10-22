import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract class IRefundRepository {
  // Yatış ID'sine göre master kabinde iade edilebilecekleri getirir
  Future<Result<List<CabinTargetedPrescriptionItem>>> getMasterRefundables({required int hospitalizationId});

  // Yatış ID'sine göre mobil kabinde iade edilebilecekleri getirir
  Future<Result<List<PrescriptionItem>>> getMobileRefundables({required int hospitalizationId});

  // İlgili ilaç için iade durumunu kontrol eder
  Future<Result<CabinTargetedPrescriptionItem?>> checkMasterRefundStatus({required int id, required double quantity});

  // İlgili ilaç için iade durumunu kontrol eder
  Future<Result<void>> checkMobileRefundStatus({required int id, required double quantity});

  // İlaç İade İşlemi - Mobil Kabin(Eczacıya iade ediliyor)
  Future<Result<void>> refundMobile({required int id, required double quantity});

  // İlaç İade İşlemi - İade Kutusuna İade
  Future<Result<int?>> refundToBox({required int id, required double quantity});

  // İlaç İade İşlemi - Eczaneye İade
  Future<Result<int?>> refundToPharmacy({required int id, required double quantity});

  // İlaç İade İşlemi - Çekmeceye İade
  Future<Result<int?>> refundToDrawer({required int id, required double quantity});

  // İlaç İade İşlemi - Çekmeceye İade
  Future<Result<int?>> refundToOrigin({required int id, required double quantity, required int cabinDrawerDetailId});

  // Eczaneye iade edilen ilaçları getirir
  Future<Result<ApiResponse<List<Refund>>?>> getPharmacyRefunds({PagedQueryParams? params, required int stationId});

  // Eczaneye iade edilen ilacın iadesinin tamamlanması işlemi
  Future<Result<void>> completePharmacyRefund(int id);

  // Eczaneye iade edilmiş ve eczacının tamamladığı iadeleri getirir
  Future<Result<ApiResponse<List<Refund>>?>> getCompletedPharmacyRefunds({
    PagedQueryParams? params,
    required int stationId,
  });

  // Çekmeceye iade edilen ilaçları getirir
  Future<Result<ApiResponse<List<Refund>>?>> getDrawerRefunds({PagedQueryParams? params, required int stationId});

  // İade kutusuna iade edilen ilaçları getirir
  Future<Result<ApiResponse<List<Refund>>?>> getReturnBoxRefunds({PagedQueryParams? params, required int stationId});

  // İade silme işlemi
  Future<Result<void>> deletePharmacyRefund(int refundId, String? description);
}
