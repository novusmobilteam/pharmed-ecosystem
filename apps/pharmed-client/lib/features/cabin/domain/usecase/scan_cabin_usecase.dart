/lib/src/cabin/domain/usecase/save_cabin_design_usecase.dart
//
// [SWREQ-CORE-CABIN-UC-010]
// Sınıf: Class B

import 'package:pharmed_client/core/hardware/service/cabin_operation/i_cabin_operation_service.dart';
import 'package:pharmed_client/core/hardware/service/serial_communication/i_serial_communication_service.dart';
import 'package:pharmed_core/pharmed_core.dart';

class ScanCabinUseCase {
  final ICabinRepository _cabinRepository;
  final ICabinOperationService _cabinOperationService;
  final ISerialCommunicationService _serialService;

  ScanCabinUseCase({
    required ICabinRepository cabinRepository,
    required ICabinOperationService cabinOperationService,
    required ISerialCommunicationService serialService,
  }) : _cabinRepository = cabinRepository,
       _cabinOperationService = cabinOperationService,
       _serialService = serialService;

  Future<Result<List<DrawerGroup>>> call({
    String? portName,
    required CabinType cabinType,
    Function(String)? onStatusChanged,
  }) async {
    try {
      // 1. Seri Port Bağlantısı
      await _serialService.connectToPort(portName ?? "COM3", onStatusChanged: onStatusChanged);

      // 2. Veritabanındaki Tanımları Paralel Çek
      final results = await Future.wait([_cabinRepository.getDrawerConfigs(), _cabinRepository.getDrawerTypes()]);

      final configsRes = results[0] as Result<List<DrawerConfig>>;
      final typesRes = results[1] as Result<List<DrawerType>>;

      if (configsRes is! Ok || typesRes is! Ok) {
        return Result.error(CustomException(message: "Tanımlamalar alınamadı."));
      }

      final allConfigs = (configsRes as Ok).value;
      final allTypes = (typesRes as Ok).value;

      // 3. Donanım Taraması
      final manager = await _cabinOperationService.findManagementCard();
      if (manager == null) return Result.error(CustomException(message: 'Yönetim kartı bulunamadı.'));

      final controlCards = await _cabinOperationService.findControlCards(manager);
      if (controlCards.isEmpty) return Result.error(CustomException(message: 'Hiçbir kart bulunamadı.'));

      final List<DrawerGroup> foundGroups = [];

      for (final card in controlCards) {
        final typeNo = card.databaseTypeId;

        // Config bul
        final DrawerConfig? config = allConfigs.cast<DrawerConfig?>().firstWhere(
          (c) => c?.deviceTypeNo == typeNo,
          orElse: () => null,
        );
        if (config == null) continue;

        // Type bul
        final type = allTypes.cast<DrawerType?>().firstWhere((t) => t?.id == config.drawerTypeId, orElse: () => null);
        if (type == null) continue;

        // Serum filtrelemesi (İhtiyaç varsa)
        final bool isSerumHardware = (typeNo == 250);

        if (cabinType == CabinType.serum) {
          // Sadece serum kartlarını (250) kabul et
          if (!isSerumHardware) continue;
        } else {
          // Standart kabinlerde serum kartlarını (250) ele
          if (isSerumHardware) continue;
        }

        final slot = DrawerSlot(
          address: card.rowAddress.toString().padLeft(2, '0'),
          orderNumber: card.rowAddress,
          drawerConfigId: config.id,
          drawerConfig: config.copyWith(drawerType: type),
        );

        final int totalCells = type.compartmentCount ?? 0;

        final List<DrawerUnit> generatedUnits = List.generate(
          totalCells,
          (index) => DrawerUnit(id: null, compartmentNo: index + 1),
        );

        foundGroups.add(DrawerGroup(slot: slot, units: generatedUnits));
      }

      return Result.ok(foundGroups);
    } catch (e) {
      return Result.error(CustomException(message: e.toString()));
    }
  }
}
