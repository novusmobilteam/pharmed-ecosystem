// [SWREQ-CORE-CABIN-UC-009]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class SaveCabinDesignUseCase {
  SaveCabinDesignUseCase({required ICabinRepository cabinRepository, required ICabinLocalDataSource localDataSource})
    : _cabinRepository = cabinRepository,
      _localDataSource = localDataSource;

  final ICabinRepository _cabinRepository;
  final ICabinLocalDataSource _localDataSource;

  Future<Result<void>> call({
    required int cabinId,
    required List<DrawerSlot> scanResults,
    required bool isUpdate,
  }) async {
    // Adres sıralaması
    final sorted = [...scanResults]..sort((a, b) => (a.address ?? '').compareTo(b.address ?? ''));

    if (scanResults.isEmpty) {
      return Result.error(ServiceException(message: "Kaydedilecek veri bulunamadı.", statusCode: 404));
    }

    final slots = sorted.indexed.map((entry) {
      final (i, slot) = entry;
      return slot.copyWith(cabinId: cabinId, orderNumber: i + 1);
    }).toList();

    final result = isUpdate
        ? await _cabinRepository.updateDrawerSlots(slots)
        : await _cabinRepository.createDrawerSlots(slots);

    return result.when(
      error: Result.error,
      ok: (_) async {
        // ── Cache'e yaz ──────────────────────────────────────
        // DTO dönüşümü mapper ile
        final dtos = slots.map((s) => const DrawerSlotMapper().toDto(s)).toList();
        await _localDataSource.saveSlots(cabinId, dtos);

        MedLogger.info(
          unit: 'SW-UNIT-DATA',
          swreq: 'SWREQ-DATA-CABIN-003',
          message: 'Slot tasarımı cache\'e yazıldı',
          context: {'cabinId': cabinId, 'slotCount': slots.length},
        );

        return const Result.ok(null);
      },
    );
  }
}
