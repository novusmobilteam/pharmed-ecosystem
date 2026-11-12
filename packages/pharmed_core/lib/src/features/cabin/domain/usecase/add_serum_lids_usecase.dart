// [SWREQ-CORE-CABIN-SERUM-002] [IEC 62304 §5.5]
// Kayıtlı bağımsız serum kabinine kapak ekler (#199).
// Yeni kapaklar POST /CabinDesign/bulk ile ayrı DrawerSlot olarak oluşturulur:
// adres satır 26, orderNumber = kapak no. Mevcut kapaklara dokunulmaz.
// Kapak kaldırma için backend'de silme servisi yok — desteklenmiyor.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class AddSerumLidsUseCase {
  const AddSerumLidsUseCase({required ICabinRepository cabinRepository}) : _cabinRepository = cabinRepository;

  final ICabinRepository _cabinRepository;

  static const _unit = 'SW-UNIT-CABIN';
  static const _swreq = 'SWREQ-CORE-CABIN-SERUM-002';

  /// [lids]: kabinin mevcut kapak slot'ları (en az bir tane; tanım ve adres
  /// buradan alınır). [newCount]: hedef kapak sayısı (> mevcut, ≤ 4).
  Future<Result<void>> call({required int cabinId, required List<DrawerSlot> lids, required int newCount}) async {
    final template = lids.firstOrNull;
    final current = lids.length;
    if (template == null || newCount <= current || newCount > DeviceConstants.maxSerumLids) {
      MedLogger.ruleRejected(
        unit: _unit,
        swreq: _swreq,
        rule: 'SERUM_LID_LIMIT',
        context: {'cabinId': cabinId, 'current': current, 'requested': newCount},
      );
      return Result.error(
        BusinessRuleException(
          message: contextlessL10n().cabinDesign_serum_lidLimitError(DeviceConstants.maxSerumLids),
          ruleCode: 'SERUM_LID_LIMIT',
        ),
      );
    }

    // Boşalan en küçük kapak numaraları kullanılır (#203) — kapak no = port.
    final free = SerumLids.freeLidNumbers(lids).take(newCount - current);
    final slots = [
      for (final lid in free)
        DrawerSlot(
          drawerConfigId: template.drawerConfigId,
          cabinId: cabinId,
          orderNumber: lid,
          address: template.address,
          isReturnDrawerHere: false,
        ),
    ];

    final result = await _cabinRepository.createDrawerSlots(slots);
    result.when(
      ok: (_) => MedLogger.info(
        unit: _unit,
        swreq: _swreq,
        message: 'Serum kabinine kapak eklendi',
        context: {'cabinId': cabinId, 'from': current, 'to': newCount},
      ),
      error: (e) => MedLogger.error(unit: _unit, swreq: _swreq, message: 'Serum kapağı eklenemedi', error: e),
    );
    return result;
  }
}
