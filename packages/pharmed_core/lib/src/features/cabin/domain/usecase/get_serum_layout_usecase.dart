// [SWREQ-CORE-CABIN-SERUM-001] [IEC 62304 §5.5]
// Serum kabininin kayıtlı raf/avadanlık yerleşimini getirir.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetSerumLayoutUseCase {
  const GetSerumLayoutUseCase({required ICabinRepository cabinRepository}) : _cabinRepository = cabinRepository;

  final ICabinRepository _cabinRepository;

  /// Her zaman 3 raf döner (Raf 1 en üst). Hiç kayıt yoksa raflar boş ve id'siz.
  Future<Result<List<SerumShelfLayout>>> call(int serumSlotId) => _cabinRepository.getSerumLayout(serumSlotId);
}
