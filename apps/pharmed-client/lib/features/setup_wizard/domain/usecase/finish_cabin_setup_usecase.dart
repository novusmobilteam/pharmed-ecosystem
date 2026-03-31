// [SWREQ-SETUP-UC-001] [IEC 62304 §5.5]
// İlk kurulum wizard'ı tamamlama use case'i.
// Kabin oluşturur, standart kabinlerde çekmece slot'larını kaydeder.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

import '../../../cabin/cabin.dart';
import '../model/cabin_setup_config.dart';

class FinishCabinSetupUseCase {
  FinishCabinSetupUseCase({
    required CreateCabinUseCase createCabinUseCase,
    required SaveCabinDesignUseCase saveCabinDesignUseCase,
  }) : _createCabin = createCabinUseCase,
       _saveCabinDesign = saveCabinDesignUseCase;

  final CreateCabinUseCase _createCabin;
  final SaveCabinDesignUseCase _saveCabinDesign;

  /// Wizard konfigürasyonunu alır, kabini oluşturur ve gerekirse slot'ları kaydeder.
  ///
  /// Dönüş: [Result<int>] — başarıda oluşturulan kabinin ID'si.
  ///
  /// Standart kabin akışı:
  ///   1. [CreateCabinUseCase] → Cabin kaydı oluştur, cabinId al
  ///   2. [SaveCabinDesignUseCase] → DrawerSlot'ları cabinId ile kaydet
  ///
  /// Mobil kabin akışı:
  ///   1. [CreateCabinUseCase] → Cabin kaydı oluştur (slot kayıt henüz desteklenmiyor)
  Future<Result<int>> call(CabinSetupConfig config) async {
    // ── Cabin entity oluştur ───────────────────────────────────
    final cabin = Cabin(
      name: config.basicInfo.cabinName,
      type: config.cabinetType,
      comPort: ComPortX.fromLabel(config.basicInfo.comPort),
      dvrIp: config.basicInfo.dvrIp,
      status: Status.active,
      station: config.serviceScope is ServiceBased
          ? Station(id: int.tryParse((config.serviceScope as ServiceBased).departmentId ?? ''))
          : null,
    );

    // ── 1. Kabini oluştur ──────────────────────────────────────
    final createResult = await _createCabin(cabin);

    return createResult.when(
      error: Result.error,
      ok: (createdCabin) async {
        final cabinId = createdCabin?.id;

        if (cabinId == null) {
          return Result.error(ServiceException(message: 'Kabin oluşturuldu fakat ID alınamadı.', statusCode: 500));
        }

        // ── 2. Standart kabin → slot'ları kaydet ──────────────
        if (config.cabinetType != CabinType.mobile) {
          final slots = config.scannedLayout?.map((g) => g.slot).toList() ?? [];

          if (slots.isNotEmpty) {
            final saveResult = await _saveCabinDesign(cabinId: cabinId, scanResults: slots, isUpdate: false);

            return saveResult.when(error: Result.error, ok: (_) => Result.ok(cabinId));
          }
        }

        // Mobil kabin veya slot listesi boş
        return Result.ok(cabinId);
      },
    );
  }
}
