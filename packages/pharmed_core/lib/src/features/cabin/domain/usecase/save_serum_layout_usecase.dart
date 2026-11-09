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
      MedLogger.warn(
        unit: _unit,
        swreq: _swreq,
        message: 'Serum yerleşimi geçersiz',
        context: {'slotId': serumSlotId, 'reason': invalid.reason, 'rule': invalid.error.ruleCode},
      );
      return Result.error(invalid.error);
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

  /// Savunma amaçlı kontrol — UI ve yerleşimin okunması
  /// (SerumLayoutMapper.validate) zaten bu sınırları uyguluyor. Geçersizse
  /// log için sebep ve kullanıcıya gösterilecek hata döner.
  static ({String reason, BusinessRuleException error})? _validate(List<SerumShelfLayout> shelves) {
    const total = SerumShelfLayout.shelfCount;
    final orderList = shelves.map((s) => s.orderNo).toList();

    BusinessRuleException invalidOrder() => BusinessRuleException(
      message: contextlessL10n().cabinDesign_serum_invalidLayoutError(orderList.join(', ')),
      ruleCode: 'SERUM_LAYOUT_INVALID_ORDER',
    );

    if (shelves.length != total) return (reason: 'shelfCount=${shelves.length}', error: invalidOrder());
    final orders = orderList.toSet();
    if (orders.length != total || orders.any((o) => o < 1 || o > total)) {
      return (reason: 'orderNo=$orders', error: invalidOrder());
    }
    for (final s in shelves) {
      if (s.usedArea > SerumShelfLayout.totalArea) {
        return (
          reason: 'shelf ${s.orderNo} usedArea=${s.usedArea}',
          error: BusinessRuleException(
            message: contextlessL10n().cabinDesign_serum_capacityFullWarning,
            ruleCode: 'SERUM_SHELF_AREA_EXCEEDED',
          ),
        );
      }
    }
    // Kısmi kayıt olmamalı: ya hepsi kayıtlı (PUT) ya hiçbiri (POST).
    final persisted = shelves.where((s) => s.isPersisted).length;
    if (persisted != 0 && persisted != total) {
      return (
        reason: 'persisted=$persisted',
        error: BusinessRuleException(
          message: contextlessL10n().cabinDesign_serum_incompleteLayoutError(persisted, total),
          ruleCode: 'SERUM_LAYOUT_INCOMPLETE',
        ),
      );
    }
    return null;
  }
}
