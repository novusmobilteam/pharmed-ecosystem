// [SWREQ-CORE-CABIN-SERUM-001] [IEC 62304 §5.5]
// Serum kabininin raf/avadanlık yerleşimini kaydeder.
// Yerleşim kullanıcı tanımlıdır; fiziksel tarama yapılmaz.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class SaveSerumLayoutUseCase {
  const SaveSerumLayoutUseCase({required ICabinRepository cabinRepository}) : _cabinRepository = cabinRepository;

  final ICabinRepository _cabinRepository;

  static const _unit = 'SW-UNIT-CABIN';
  static const _swreq = 'SWREQ-CORE-CABIN-SERUM-001';

  /// [serumSlotId]: serum kabininin DrawerSlot.id'si.
  /// [shelves]: 3 raf; her raftaki avadanlıklar sağdan sola sırayla.
  ///
  /// Raflar kayıtlıysa (id'li) güncelleme (PUT), değilse ilk kayıt (POST).
  Future<Result<void>> call({required int serumSlotId, required List<SerumShelfLayout> shelves}) async {
    final invalid = _validate(shelves);
    if (invalid != null) {
      MedLogger.warn(unit: _unit, swreq: _swreq, message: 'Serum yerleşimi geçersiz', context: {'reason': invalid});
      return const Result.error(UnexpectedException());
    }

    final result = await _cabinRepository.saveSerumLayout(slotId: serumSlotId, shelves: shelves);

    result.when(
      ok: (_) => MedLogger.info(
        unit: _unit,
        swreq: _swreq,
        message: 'Serum yerleşimi kaydedildi',
        context: {
          'slotId': serumSlotId,
          'mode': shelves.any((s) => s.isPersisted) ? 'update' : 'create',
          'shelves': shelves.map((s) => '${s.orderNo}:${s.lockType.name}:${s.trays.length}').join(','),
        },
      ),
      error: (e) => MedLogger.error(unit: _unit, swreq: _swreq, message: 'Serum yerleşimi kaydedilemedi', error: e),
    );

    return result;
  }

  /// Savunma amaçlı kontrol — UI zaten bu sınırları uyguluyor.
  static String? _validate(List<SerumShelfLayout> shelves) {
    if (shelves.length != SerumShelfLayout.shelfCount) return 'shelfCount=${shelves.length}';
    final orders = shelves.map((s) => s.orderNo).toSet();
    if (orders.length != SerumShelfLayout.shelfCount || orders.any((o) => o < 1 || o > SerumShelfLayout.shelfCount)) {
      return 'orderNo=$orders';
    }
    for (final s in shelves) {
      if (s.usedArea > SerumShelfLayout.totalArea) return 'shelf ${s.orderNo} usedArea=${s.usedArea}';
    }
    // Kısmi kayıt olmamalı: ya hepsi kayıtlı (PUT) ya hiçbiri (POST).
    final persisted = shelves.where((s) => s.isPersisted).length;
    if (persisted != 0 && persisted != shelves.length) return 'persisted=$persisted';
    return null;
  }
}
