import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IIntakeRepository {
  // İlaç Alım Ekranı
  // Reçete ID'sine göre alınacakları getirir
  Future<Result<List<CabinTargetedPrescriptionItem>>> getIntakeItems({required int hospitalizationId});

  /// İlaç Alım İşlemi - Kontrol
  /// Alım yaparken önce alım türüne göre (IntakeType) alım işlemini kontrol
  /// ediyoruz. Eğer bu alım işlemi yapılabilecekse (Günlük maks. kullanım miktarı vb)
  /// bu servisler başarılı dönüyor ve ardından alım işlemine başlıyoruz.
  Future<Result<void>> checkOrderedIntake(Map<String, dynamic> data);
  Future<Result<void>> checkOrderlessIntake(Map<String, dynamic> data);
  Future<Result<void>> checkFreeIntake(Map<String, dynamic> data);

  /// İlaç Alım İşlemi - Tamamlama
  /// Kontrol işlemleri başarılı olursa alım türüne göre ilgili servis ile
  /// alım işlemini tamamlıyoruz.
  Future<Result<void>> completeOrderedIntake(Map<String, dynamic> data);
  Future<Result<void>> completeOrderlessIntake(Map<String, dynamic> data);
  Future<Result<void>> completeFreeIntake(Map<String, dynamic> data);

  Future<Result<void>> definePatientMedicine(Map<String, dynamic> data);

  // Hastaya tanımlı ilaçların getirilmesi işlemi
  Future<Result<List<PatientMedicineIntakeItem>>> getPatientMedicines({required int hospitalizationId});

  // Hastaya tanımlı ilaçların alınması işlemi
  Future<Result<void>> intakePatientMedicine({required int id});

  /// Mobil kabin ilaç kontrol ve alım işlemleri
  Future<Result<void>> checkMobileIntake(List<Map<String, dynamic>> data);
  Future<Result<void>> completeMobileIntake(List<Map<String, dynamic>> data);
}
