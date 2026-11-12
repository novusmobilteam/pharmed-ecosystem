// [SWREQ-SCAN-002] [IEC 62304 §5.5]
// Fiziksel kabin tarama use case'i.
// Seri port üzerinden bağlanır, çekmece yapısını okur ve DrawerGroup listesi döner.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

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
  /// [portName]           : Bağlanılacak seri port (ör. "COM3"). null ise varsayılan port kullanılır.
  /// [cabinType]           : Taranacak kabin tipi — serum kartı filtrelemesi için gerekli.
  /// [targetAddressIndex]  : Bu kabinin yönetim kartı adresi (1-16). null ise eski davranış —
  ///                         önce A denenir, bulunamazsa 1-16 tam taranır. Çoklu kabin senaryosunda
  ///                         [Cabin.no] alanından [ManagementCard.indexFromAddressChar] ile üretilip
  ///                         geçilmelidir; aksi halde yanlış kabin bulunabilir.
  /// [onStatusChanged]     : Her adımda tetiklenen callback.
  ///                         [status] adımın türünü, [detail] opsiyonel ek bilgiyi taşır.
  Future<Result<List<DrawerGroup>>> call({
    String? portName,
    required CabinType cabinType,
    int? targetAddressIndex,
    void Function(ScanStatus status, {String? detail})? onStatusChanged,
  }) async {
    try {
      // ── 1. Seri Port Bağlantısı ────────────────────────────────
      onStatusChanged?.call(ScanStatus.connecting, detail: portName);

      await _serialService.connectToPort(
        portName ?? 'COM8',
        onStatusChanged: (_) {}, // ScanStatus üzerinden yönetiliyor
      );

      onStatusChanged?.call(ScanStatus.connected, detail: portName);

      // ── 2. Meta Veri (Paralel) ─────────────────────────────────
      onStatusChanged?.call(ScanStatus.fetchingMetadata);

      // Tanımlar taramada her zaman backend'den tazelenir: cihaz cache'i süresiz
      // tutulduğu için backend'de sonradan eklenen/değişen çekmece tanımları
      // (ör. 20 gözlü kübik) aksi halde hiç görülmez. Ağ yoksa cache'e düşülür.
      final allConfigs = await _loadDrawerConfigs();
      final allTypes = await _loadDrawerTypes();

      // Herhangi biri başarısız → tarama durur
      if (allConfigs == null || allTypes == null) {
        onStatusChanged?.call(ScanStatus.metadataFailed, detail: 'Tanımlamalar alınamadı.');
        return Result.error(CustomException(message: contextlessL10n().cabinCore_definitionsNotFound));
      }

      onStatusChanged?.call(ScanStatus.metadataReady, detail: '${allConfigs.length} konfigürasyon');
      _warnDuplicateDeviceTypeNos(allConfigs);

      // ── 3. Yönetim Kartı ───────────────────────────────────────
      onStatusChanged?.call(ScanStatus.searchingManager, detail: targetAddressIndex?.toString());

      final manager = await _cabinOperationService.scanManagementCard(targetAddressIndex: targetAddressIndex);
      if (manager == null) {
        onStatusChanged?.call(ScanStatus.managerNotFound);
        return Result.error(CustomException(message: contextlessL10n().core_cabinConn_managerNotFoundError));
      }

      onStatusChanged?.call(ScanStatus.managerFound, detail: 'Adres: ${manager.addressIndex}');

      // ── 4. Kontrol Kartları ────────────────────────────────────
      onStatusChanged?.call(ScanStatus.scanningCards);

      final controlCards = await _cabinOperationService.discoverControlCards(manager, expectedType: cabinType);
      if (controlCards.isEmpty) {
        onStatusChanged?.call(ScanStatus.noCardsFound);
        return Result.error(CustomException(message: contextlessL10n().cabinCore_noCardsFound));
      }

      // Bir yönetim kartında birden fazla serum (250) kartı beklenmez — genelde
      // başka bir kabinde açık kalan satır seçiminin işaretidir (#189).
      final serumRows = controlCards.where((c) => c.isSerum).map((c) => c.rowAddress).toList();
      if (serumRows.length > 1) {
        MedLogger.warn(
          unit: 'SW-UNIT-SCAN',
          swreq: 'SWREQ-SCAN-002',
          message: 'Birden fazla serum kartı bulundu — başka kabinde satır seçimi açık kalmış olabilir',
          context: {'adres': manager.addressIndex, 'satirlar': serumRows},
        );
      }

      // ── 5. Eşleştirme ──────────────────────────────────────────
      final cards = _classifySerumCard(controlCards, managerAddress: manager.addressIndex);
      final List<DrawerGroup> foundGroups = [];

      for (final card in cards) {
        final typeNo = card.databaseTypeId;
        //final bool isSerumHardware = typeNo == 250;

        // if (cabinType == CabinType.serum) {
        //   if (!isSerumHardware) continue;
        // } else {
        //   if (isSerumHardware) continue;
        // }

        final DrawerConfig? config = allConfigs.cast<DrawerConfig?>().firstWhere(
          (c) => c?.deviceTypeNo == typeNo,
          orElse: () => null,
        );
        final DrawerType? type = config == null
            ? null
            : allTypes.cast<DrawerType?>().firstWhere((t) => t?.id == config.drawerTypeId, orElse: () => null);

        // Her kart için ham tip cevabı ve eşleşme sonucu kaydedilir — çekmecenin
        // yanlış tipte tanınması (ör. 20 gözlü kübik → 16) loglardan teşhis edilebilsin.
        final cardLog = {
          'satir': card.rowAddress,
          'hamCevap': card.rawTypeResponse.trim(),
          'tipNo': typeNo,
          'configId': config?.id,
          'drawerTypeId': config?.drawerTypeId,
          'tip': type?.name,
          'gozSayisi': type?.compartmentCount,
          'kubik': type?.isKubik,
        };
        if (config == null || type == null) {
          MedLogger.warn(
            unit: 'SW-UNIT-SCAN',
            swreq: 'SWREQ-SCAN-002',
            message: config == null ? 'Kart tip numarası hiçbir tanımla eşleşmedi' : 'Tanımın çekmece tipi bulunamadı',
            context: cardLog,
          );
          continue;
        }
        MedLogger.info(unit: 'SW-UNIT-SCAN', swreq: 'SWREQ-SCAN-002', message: 'Kontrol kartı eşleşti', context: cardLog);

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
        return Result.error(CustomException(message: contextlessL10n().cabinCore_noMatchingDrawerFound));
      }

      onStatusChanged?.call(ScanStatus.completed, detail: '${foundGroups.length} çekmece');

      return Result.ok(foundGroups);
    } catch (e) {
      return Result.error(CustomException(message: e.toString()));
    }
  }

  /// [#195] A dışındaki adreste satır [DeviceConstants.serumSlaveRow]'daki
  /// `.250` kabinin KENDİ serum kartıdır, çekmece değildir:
  ///   • Satır 1–25'te başka kart varsa (B) → normal kabin, serum kartı atılır.
  ///   • Yoksa (C) → bağımsız serum kabini; tek serum çekmecesi döner, kapak
  ///     sayısı kabin dizaynında sorulur ([isStandaloneSerum]).
  /// Master (A) ve kabin tipi seçimi bu kararı etkilemez — kart belirler.
  List<ControlCard> _classifySerumCard(List<ControlCard> cards, {required int managerAddress}) {
    if (managerAddress == 1) return cards;
    final serumCard = cards.where((c) => c.isSerum && c.rowAddress == DeviceConstants.serumSlaveRow).firstOrNull;
    if (serumCard == null) return cards;

    final others = cards.where((c) => !identical(c, serumCard)).toList();
    final standalone = others.isEmpty;
    MedLogger.info(
      unit: 'SW-UNIT-SCAN',
      swreq: 'SWREQ-SCAN-002',
      message: standalone
          ? 'Bağımsız serum kabini: yalnız serum kartı bulundu, kapak sayısı sorulacak'
          : 'Serum kartına bağlı kabin: serum kartı çekmece sayılmadı',
      context: {'adres': managerAddress, 'digerSatirlar': others.map((c) => c.rowAddress).toList()},
    );
    return standalone ? cards : others;
  }

  /// [#195] Tarama sonucu bağımsız serum kabini mi (C)? Kabin dizaynı bu
  /// durumda kapak sayısını (1–[DeviceConstants.maxSerumLids]) sorar.
  static bool isStandaloneSerum(List<DrawerGroup> groups) =>
      groups.length == 1 &&
      groups.single.isSerum &&
      int.tryParse(groups.single.slot.address ?? '') == DeviceConstants.serumSlaveRow;

  Future<List<DrawerConfig>?> _loadDrawerConfigs() async {
    final fresh = await _cabinRepository.getDrawerConfigs(forceRefresh: true);
    final data = fresh.when(ok: (d) => d, error: (_) => null);
    if (data != null) return data;
    MedLogger.warn(unit: 'SW-UNIT-SCAN', swreq: 'SWREQ-SCAN-002', message: 'Çekmece tanımları tazelenemedi, cache kullanılıyor');
    return (await _cabinRepository.getDrawerConfigs()).when(ok: (d) => d, error: (_) => null);
  }

  Future<List<DrawerType>?> _loadDrawerTypes() async {
    final fresh = await _cabinRepository.getDrawerTypes(forceRefresh: true);
    final data = fresh.when(ok: (d) => d, error: (_) => null);
    if (data != null) return data;
    MedLogger.warn(unit: 'SW-UNIT-SCAN', swreq: 'SWREQ-SCAN-002', message: 'Çekmece tipleri tazelenemedi, cache kullanılıyor');
    return (await _cabinRepository.getDrawerTypes()).when(ok: (d) => d, error: (_) => null);
  }

  /// Aynı cihaz tip numarasına bağlı birden fazla tanım varsa eşleştirme ilk bulunanı
  /// seçer (sessizce yanlış tip). Bu durumu görünür kılar.
  void _warnDuplicateDeviceTypeNos(List<DrawerConfig> configs) {
    final byNo = <int, List<int?>>{};
    for (final c in configs) {
      final no = c.deviceTypeNo;
      if (no == null) continue;
      byNo.putIfAbsent(no, () => []).add(c.id);
    }
    byNo.forEach((no, ids) {
      if (ids.length > 1) {
        MedLogger.warn(
          unit: 'SW-UNIT-SCAN',
          swreq: 'SWREQ-SCAN-002',
          message: 'Aynı cihaz tip numarası birden fazla tanımda — ilk tanım kullanılacak',
          context: {'tipNo': no, 'configIdler': ids},
        );
      }
    });
  }
}
