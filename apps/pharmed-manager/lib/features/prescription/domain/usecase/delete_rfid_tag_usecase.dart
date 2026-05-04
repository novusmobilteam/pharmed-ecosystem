// [SWREQ-RFID-006] [IEC 62304 §5.5]
// Reçete kalemine atanmış RFID etiketini siler.
//
// Akış:
//   1. IPrescriptionRepository.deleteRfidTag(itemId) → API isteği
//   2. Başarılıysa void döner
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteRfidTagUseCase {
  const DeleteRfidTagUseCase(this._prescriptionRepository);

  final IPrescriptionRepository _prescriptionRepository;

  Future<Result<void>> call(int prescriptionItemId) =>
      _prescriptionRepository.deleteRfidTag(prescriptionItemId: prescriptionItemId);
}
