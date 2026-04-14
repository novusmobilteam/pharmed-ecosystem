// apps/pharmed-client/lib/features/cabin/domain/usecase/save_mobile_cabin_design_use_case.dart
//
// [SWREQ-CABIN-UC-007] [IEC 62304 §5.5]
// Mobil kabin çekmece yapısını API'ye kaydeder.
// WizardDrawerConfig listesi DTO'ya dönüştürülür ve repository üzerinden gönderilir.
// Fiziksel tarama yapılmaz; tüm yapı kullanıcı tanımlıdır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../setup_wizard/domain/model/wizard_mobile_layout.dart';

class SaveMobileCabinDesignUseCase {
  const SaveMobileCabinDesignUseCase({
    required ICabinRepository cabinRepository,
    required ICabinLocalDataSource localDataSource,
  }) : _cabinRepository = cabinRepository,
       _localDataSource = localDataSource;

  final ICabinRepository _cabinRepository;
  final ICabinLocalDataSource _localDataSource;

  /// [cabinId] oluşturulan kabinin ID'si.
  /// [drawers] wizard'dan gelen çekmece konfigürasyon listesi.
  Future<Result<void>> call({required int cabinId, required List<WizardDrawerConfig> drawers}) async {
    final dtos = drawers.map((drawer) => _toDto(cabinId, drawer)).toList();

    final result = await _cabinRepository.createMobileDrawerSlots(dtos);

    return result.when(
      error: Result.error,
      ok: (_) async {
        await _localDataSource.saveMobileDrawers(cabinId, dtos);

        MedLogger.info(
          unit: 'SW-UNIT-DATA',
          swreq: 'SWREQ-CABIN-UC-007',
          message: 'Mobil kabin tasarımı cache\'e yazıldı',
          context: {'cabinId': cabinId, 'drawerCount': dtos.length},
        );

        return const Result.ok(null);
      },
    );
  }

  MobileDrawerRequestDTO _toDto(int cabinId, WizardDrawerConfig drawer) {
    final orderNumber = drawer.drawerIndex + 1;
    return MobileDrawerRequestDTO(
      cabinId: cabinId,
      orderNumber: orderNumber,
      address: orderNumber.toString(),
      details: drawer.rowColumns
          .asMap()
          .entries
          .map((e) => MobileDrawerRowDTO(orderNumber: e.key + 1, columnsCount: e.value))
          .toList(),
    );
  }
}
