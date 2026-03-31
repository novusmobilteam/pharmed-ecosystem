// [SWREQ-SCAN-002] [IEC 62304 §5.5]
// Fiziksel kabin tarama use case'i.
// Seri port üzerinden bağlanır, çekmece yapısını okur ve DrawerGroup listesi döner.
// Sınıf: Class B

import 'package:pharmed_client/core/hardware/service/cabin_operation/i_cabin_operation_service.dart';
import 'package:pharmed_client/core/hardware/service/serial_communication/i_serial_communication_service.dart';
import 'package:pharmed_core/pharmed_core.dart';

class ScanCabinUseCase {
  ScanCabinUseCase({
    required ICabinRepository cabinRepository,
    required ICabinOperationService cabinOperationService,
    required ISerialCommunicationService serialService,
  }) : _cabinRepository = cabinRepository,
       _cabinOperationService = cabinOperationService,
       _serialService = serialService;

  final ICabinRepository _cabinRepository;
  final ICabinOperationService _cabinOperationService;
  final ISerialCommunicationService _serialService;

  /// Kabini fiziksel olarak tarar ve çekmece yapısını döner.
  ///
  /// [portName]        : Bağlanılacak seri port (ör. "COM3"). null ise varsayılan port kullanılır.
  /// [cabinType]       : Taranacak kabin tipi — serum kartı filtrelemesi için gerekli.
  /// [onStatusChanged] : Her adımda tetiklenen callback.
  ///                     [status] adımın türünü, [detail] opsiyonel ek bilgiyi taşır.
  Future<Result<List<DrawerGroup>>> call({
    String? portName,
    required CabinType cabinType,
    void Function(ScanStatus status, {String? detail})? onStatusChanged,
  }) async {
    try {
      // ── 1. Seri Port Bağlantısı ────────────────────────────────
      onStatusChanged?.call(ScanStatus.connecting, detail: portName);

      await _serialService.connectToPort(
        portName ?? 'COM3',
        onStatusChanged: (_) {}, // ScanStatus üzerinden yönetiliyor
      );

      onStatusChanged?.call(ScanStatus.connected, detail: portName);

      // ── 2. Meta Veri (Paralel) ─────────────────────────────────
      onStatusChanged?.call(ScanStatus.fetchingMetadata);

      final results = await Future.wait([_cabinRepository.getDrawerConfigs(), _cabinRepository.getDrawerTypes()]);

      final configsRes = results[0] as RepoResult<List<DrawerConfig>>;
      final typesRes = results[1] as RepoResult<List<DrawerType>>;

      // RepoFailure → tarama durduruluyor
      // RepoStale → cache var, taramaya devam edilebilir
      if (configsRes is RepoFailure || typesRes is RepoFailure) {
        onStatusChanged?.call(ScanStatus.metadataFailed, detail: 'Tanımlamalar alınamadı.');
        return Result.error(CustomException(message: 'Tanımlamalar alınamadı.'));
      }

      final allConfigs = configsRes.dataOrNull!;
      final allTypes = typesRes.dataOrNull!;

      onStatusChanged?.call(
        ScanStatus.metadataReady,
        detail: '${allConfigs.length} konfigürasyon${configsRes.isStale ? ' (önbellek)' : ''}',
      );

      // ── 3. Yönetim Kartı ───────────────────────────────────────
      onStatusChanged?.call(ScanStatus.searchingManager);

      final manager = await _cabinOperationService.findManagementCard();
      if (manager == null) {
        onStatusChanged?.call(ScanStatus.managerNotFound);
        return Result.error(CustomException(message: 'Yönetim kartı bulunamadı.'));
      }

      onStatusChanged?.call(ScanStatus.managerFound, detail: 'Adres: ${manager.addressIndex}');

      // ── 4. Kontrol Kartları ────────────────────────────────────
      onStatusChanged?.call(ScanStatus.scanningCards);

      final controlCards = await _cabinOperationService.findControlCards(manager);
      if (controlCards.isEmpty) {
        onStatusChanged?.call(ScanStatus.noCardsFound);
        return Result.error(CustomException(message: 'Hiçbir kart bulunamadı.'));
      }

      // ── 5. Eşleştirme ──────────────────────────────────────────
      final List<DrawerGroup> foundGroups = [];

      for (final card in controlCards) {
        final typeNo = card.databaseTypeId;
        final bool isSerumHardware = typeNo == 250;

        if (cabinType == CabinType.serum) {
          if (!isSerumHardware) continue;
        } else {
          if (isSerumHardware) continue;
        }

        final DrawerConfig? config = allConfigs.cast<DrawerConfig?>().firstWhere(
          (c) => c?.deviceTypeNo == typeNo,
          orElse: () => null,
        );
        if (config == null) continue;

        final DrawerType? type = allTypes.cast<DrawerType?>().firstWhere(
          (t) => t?.id == config.drawerTypeId,
          orElse: () => null,
        );
        if (type == null) continue;

        final slot = DrawerSlot(
          address: card.rowAddress.toString().padLeft(2, '0'),
          orderNumber: card.rowAddress,
          drawerConfigId: config.id,
          drawerConfig: config.copyWith(drawerType: type),
        );

        final List<DrawerUnit> generatedUnits = List.generate(
          type.compartmentCount ?? 0,
          (index) => DrawerUnit(id: null, compartmentNo: index + 1),
        );

        foundGroups.add(DrawerGroup(slot: slot, units: generatedUnits));

        onStatusChanged?.call(ScanStatus.drawerFound, detail: '${foundGroups.length}. Çekmece — ${type.name ?? '—'}');
      }

      if (foundGroups.isEmpty) {
        onStatusChanged?.call(ScanStatus.noCardsFound);
        return Result.error(CustomException(message: 'Eşleşen çekmece bulunamadı.'));
      }

      onStatusChanged?.call(ScanStatus.completed, detail: '${foundGroups.length} çekmece');

      return Result.ok(foundGroups);
    } catch (e) {
      return Result.error(CustomException(message: e.toString()));
    }
  }
}
