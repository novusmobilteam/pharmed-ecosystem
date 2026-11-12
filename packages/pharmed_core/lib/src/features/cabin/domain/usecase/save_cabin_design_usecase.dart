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
    // Aynı adresteki kayıtlar (bağımsız serum kabininin kapakları, satır 26)
    // kendi sıralarını korumalı: kapak no = orderNumber = port (#193).
    // List.sort kararlı değildir — eşit adreste orderNumber'a bakılır.
    final sorted = [...scanResults]
      ..sort((a, b) {
        final byAddress = (a.address ?? '').compareTo(b.address ?? '');
        return byAddress != 0 ? byAddress : (a.orderNumber ?? 0).compareTo(b.orderNumber ?? 0);
      });

    if (scanResults.isEmpty) {
      return Result.error(ServiceException(message: contextlessL10n().cabinCore_designDataNotFound, statusCode: 404));
    }

    final slots = sorted.indexed.map((entry) {
      final (i, slot) = entry;
      // Taramadan gelen slot'ta bayrak null → false. Çekmece değişimi kaydı
      // değişmeyen iade çekmecesinin bayrağını taşır; ezilmemeli.
      // Serum kapağında orderNumber kapak no = port'tur (#193, #203); sıra
      // numarasıyla yeniden numaralanmaz (silinmiş kapak boşluğu korunur).
      return slot.copyWith(
        cabinId: cabinId,
        orderNumber: SerumLids.isLid(slot) ? slot.orderNumber : i + 1,
        isReturnDrawerHere: slot.isReturnDrawerHere ?? false,
      );
    }).toList();

    final result = isUpdate
        ? await _cabinRepository.updateDrawerSlots(slots)
        : await _cabinRepository.createDrawerSlots(slots);

    return result.when(
      error: Result.error,
      ok: (_) async {
        final dtos = slots.map((s) => const DrawerSlotMapper().toDto(s)).toList();
        await _localDataSource.saveSlots(cabinId, dtos);

        return const Result.ok(null);
      },
    );
  }
}
