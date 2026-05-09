// [SWREQ-MGR-RX-007] [IEC 62304 §5.5]
// Reçete onaylama use case'i — check + approve iki adımlı akış.
//
// Akış:
//   1. checkPrescriptionRequests() → CheckException dönerse kullanıcıya uyarı gösterilir
//   2. Başarılıysa approvePrescriptionRequests() → void döner
//
// Notifier check hatasında kullanıcıya sorar, onay verirse
// approveOnly() ile direkt onay adımını çalıştırır.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CheckAndApprovePrescriptionUseCase {
  const CheckAndApprovePrescriptionUseCase(this._repository);

  final IPrescriptionRepository _repository;

  /// Check + approve birlikte çalıştırır.
  ///
  /// Dönüş:
  ///   - [Result.ok(null)]           → her iki adım başarılı
  ///   - [Result.error(CheckException)] → check uyarısı, kullanıcı onayı bekleniyor
  ///   - [Result.error(AppException)]   → approve hatası
  Future<Result<void>> call(int prescriptionId, List<int> itemIds) async {
    print(itemIds);
    print(prescriptionId);
    // 1. Check
    final checkResult = await _repository.checkPrescriptionRequests(prescriptionId, itemIds);
    final checkError = checkResult.when(ok: (_) => null, error: (e) => e);

    if (checkError != null) {
      return Result.error(CheckException(message: checkError.message));
    }

    // 2. Approve
    return _approveItems(prescriptionId, itemIds);
  }

  /// Check uyarısı gösterildikten sonra kullanıcı "Devam Et" derse çağrılır.
  /// Check adımı atlanır, direkt approve çalışır.
  Future<Result<void>> approveOnly(int prescriptionId, List<int> itemIds) => _approveItems(prescriptionId, itemIds);

  Future<Result<void>> _approveItems(int prescriptionId, List<int> itemIds) =>
      _repository.approvePrescriptionRequests(prescriptionId, itemIds);
}
