// [SWREQ-CORE-CABIN-UC-009]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class SaveCabinDesignUseCase {
  final ICabinRepository _cabinRepository;

  SaveCabinDesignUseCase({required ICabinRepository cabinRepository}) : _cabinRepository = cabinRepository;

  Future<Result<void>> call({
    required int cabinId,
    required List<DrawerSlot> scanResults,
    required bool isUpdate,
  }) async {
    if (scanResults.isEmpty) {
      return Result.error(ServiceException(message: "Kaydedilecek veri bulunamadı.", statusCode: 404));
    }

    try {
      // 1. ADRES SIRALAMASI
      // Önce fiziksel adreslere (01, 02...) göre diziyoruz ki
      // orderNumber fiziksel dizilimle (üstten aşağıya) tam eşleşsin.
      final List<DrawerSlot> sortedSlots = List.from(scanResults);
      sortedSlots.sort((a, b) => (a.address ?? "").compareTo(b.address ?? ""));

      // 2. VERİ HAZIRLAMA
      // Her bir slotun kabin ID'sini ve DB için nihai sıra numarasını (index + 1) veriyoruz.
      final List<DrawerSlot> preparedSlots = [];
      for (int i = 0; i < sortedSlots.length; i++) {
        preparedSlots.add(sortedSlots[i].copyWith(cabinId: cabinId, orderNumber: i + 1));
      }

      // 3. REPOSITORY ÇAĞRISI
      if (isUpdate) {
        return await _cabinRepository.updateDrawerSlots(preparedSlots);
      } else {
        return await _cabinRepository.createDrawerSlots(preparedSlots);
      }
    } catch (e) {
      return Result.error(
        ServiceException(message: "Tasarım kaydedilirken hata oluştu: ${e.toString()}", statusCode: e.hashCode),
      );
    }
  }
}
