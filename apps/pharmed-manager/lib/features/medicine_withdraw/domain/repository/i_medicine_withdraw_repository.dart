import '../../../../core/core.dart';
import '../entity/medicine_withdraw_item.dart';
import '../entity/patient_medicine_withdraw_item.dart';

abstract class IMedicineWithdrawRepository {
  // İlaç Alım Ekranı
  // Reçete ID'sine göre alınacakları getirir
  Future<Result<List<MedicineWithdrawItem>>> getWithdrawItems({required int hospitalizationId});

  /// İlaç Alım İşlemi - Kontrol
  /// Alım yaparken önce alım türüne göre (WithdrawType) alım işlemini kontrol
  /// ediyoruz. Eğer bu alım işlemi yapılabilecekse (Günlük maks. kullanım miktarı vb)
  /// bu servisler başarılı dönüyor ve ardından alım işlemine başlıyoruz.
  Future<Result<void>> checkOrderedWithdraw(Map<String, dynamic> data);
  Future<Result<void>> checkOrderlessWithdraw(Map<String, dynamic> data);
  Future<Result<void>> checkFreeWithdraw(Map<String, dynamic> data);

  /// İlaç Alım İşlemi - Tamamlama
  /// Kontrol işlemleri başarılı olursa alım türüne göre ilgili servis ile
  /// alım işlemini tamamlıyoruz.
  Future<Result<void>> completeOrderedWithdraw(Map<String, dynamic> data);
  Future<Result<void>> completeOrderlessWithdraw(Map<String, dynamic> data);
  Future<Result<void>> completeFreeWithdraw(Map<String, dynamic> data);

  Future<Result<void>> definePatientMedicine(Map<String, dynamic> data);

  // Hastaya tanımlı ilaçların getirilmesi işlemi
  Future<Result<List<PatientMedicineWithdrawItem>>> getPatientMedicines({required int hospitalizationId});

  // Hastaya tanımlı ilaçların alınması işlemi
  Future<Result<void>> withdrawPatientMedicine({required int id});
}
