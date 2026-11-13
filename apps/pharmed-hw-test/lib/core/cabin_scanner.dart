// Birleşik "Kabini tara": hat taraması (a–p) + her yönetim kartında kart
// taraması (satır 01–26) + sınıflandırma. Client'ın taramasıyla aynı servis
// metodları kullanılır (discoverControlCards). Sonuç yalnızca bellekte
// tutulur; servis tanımları değiştirilmez, client cache'ine yazılmaz.

import 'package:pharmed_core/pharmed_core.dart';

import 'cabin_model.dart';

class CabinScanResult {
  const CabinScanResult({required this.snapshot, required this.log, this.definitionsMissing = false});

  final CabinSnapshot snapshot;

  /// Rapor için ayrıntı satırları (ham cevaplar dahil).
  final List<String> log;

  /// Çekmece tanımları servisten (ve test uygulamasının kendi cache'inden)
  /// alınamadı; çekmece adları tip numarasıyla gösterilir.
  final bool definitionsMissing;
}

class CabinScanner {
  CabinScanner({required this.serial, required this.ops, required this.repository});

  final ISerialCommunicationService serial;
  final ICabinOperationService ops;
  final ICabinRepository repository;

  static const _probeTimeout = Duration(milliseconds: 300);

  /// [patientBased]: Hasta Bazlı (mobil) kabinde çekmeceler port bazlıdır ve
  /// karttan okunamaz; yalnızca yönetim kartları bulunur.
  Future<CabinScanResult> scan({required bool patientBased, void Function(String message)? onProgress}) async {
    final log = <String>[];

    List<DrawerConfig> configs = const [];
    Map<int, DrawerType> types = const {};
    var definitionsMissing = false;
    if (!patientBased) {
      onProgress?.call('Çekmece tanımları alınıyor…');
      final configsRes = await repository.getDrawerConfigs(forceRefresh: true);
      final typesRes = await repository.getDrawerTypes(forceRefresh: true);
      configs = configsRes.data ?? const [];
      types = {for (final t in typesRes.data ?? const <DrawerType>[]) if (t.id != null) t.id!: t};
      definitionsMissing = configsRes.data == null || typesRes.data == null;
      if (definitionsMissing) log.add('Çekmece tanımları servisten alınamadı; adlar tip numarasıyla gösterilir.');
    }

    final cabins = <CabinInfo>[];
    for (var address = 1; address <= 16; address++) {
      final letter = ManagementCard(addressIndex: address).addressChar.toUpperCase();
      onProgress?.call('Hat taranıyor: $letter adresi…');
      if (!await _ping(address)) continue;
      log.add('$letter: yönetim kartı cevap verdi');

      if (patientBased) {
        cabins.add(CabinInfo(addressIndex: address, kind: CabinKind.mobile, units: const []));
        continue;
      }

      onProgress?.call('$letter kabininde kartlar taranıyor (satır 01–26)…');
      final manager = ManagementCard(addressIndex: address);
      List<ControlCard> cards;
      try {
        cards = await ops.discoverControlCards(manager);
      } catch (e) {
        cards = const [];
        log.add('$letter: kart taraması hata verdi: $e');
      }
      await _release(address);

      final units = <CabinUnit>[];
      final warnings = <String>[];
      for (final card in cards) {
        final raw = card.rawTypeResponse.trim();
        log.add('$letter satır ${card.rowAddress.toString().padLeft(2, '0')}: ham $raw → tip ${card.databaseTypeId}');
        if (card.isSerum) {
          units.add(CabinRules.serumUnit(row: card.rowAddress, rawResponse: raw));
          continue;
        }
        final matches = configs.where((c) => c.deviceTypeNo == card.databaseTypeId).toList();
        final config = matches.firstOrNull;
        final type = config == null ? null : (config.drawerType ?? types[config.drawerTypeId]);
        String? problem;
        if (definitionsMissing) {
          problem = null;
        } else if (config == null) {
          problem = 'Tip ${card.databaseTypeId} hiçbir tanımla eşleşmedi';
        } else if (type == null) {
          problem = 'Tanımın çekmece tipi bulunamadı';
        } else if (matches.length > 1) {
          problem = '${matches.length} tanım aynı tip numarasında (client ilkini seçer)';
        }
        units.add(
          CabinUnit(
            row: card.rowAddress,
            kind: CabinRules.drawerKind(type),
            name: type != null ? CabinRules.drawerName(type) : 'Tip ${card.databaseTypeId}',
            compartmentCount: type?.compartmentCount,
            typeNo: card.databaseTypeId,
            rawResponse: raw,
            problem: problem,
          ),
        );
      }

      if (cards.isEmpty) warnings.add('Yönetim kartı cevap verdi ama satır 01–26\'da kart bulunamadı');
      final serumRows = units.where((u) => u.kind == UnitKind.serum).map((u) => u.rowLabel).toList();
      if (serumRows.length > 1) {
        warnings.add('Birden fazla serum kartı (satır ${serumRows.join(', ')}) — başka kabinde satır seçimi açık kalmış olabilir');
      }

      final (kind, visible) = CabinRules.classify(addressIndex: address, units: units);
      if (kind == CabinKind.noSerumCard) {
        warnings.add('A dışındaki kabinde satır 26\'da serum kartı beklenir; bulunamadı');
      }
      cabins.add(
        CabinInfo(
          addressIndex: address,
          kind: kind,
          // Serum kabininde kapaklar karttan okunamaz: kart tek birim olarak
          // görünür, kapak sayısı tanımlanmalıdır.
          units: kind == CabinKind.serumCabinet
              ? [
                  for (final u in visible)
                    CabinUnit(
                      row: u.row,
                      kind: UnitKind.serum,
                      name: 'Serum kartı',
                      typeNo: u.typeNo,
                      rawResponse: u.rawResponse,
                    ),
                ]
              : visible,
          needsLidCount: kind == CabinKind.serumCabinet,
          warnings: warnings,
        ),
      );
    }

    return CabinScanResult(
      snapshot: CabinSnapshot(source: CabinSource.scan, cabins: cabins),
      log: log,
      definitionsMissing: definitionsMissing,
    );
  }

  /// `:Y?00c;` — satır 00 aynı zamanda seçimi bırakır. İki deneme.
  Future<bool> _ping(int address) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await serial.sendAndReceive(
          CommandBuilder.buildManagementCommand(addressIndex: address, row: 0),
          timeout: _probeTimeout,
        );
        if (response != null && response.contains('ok')) return true;
      } catch (_) {}
    }
    return false;
  }

  /// Kart taramasından sonra hatta açık satır seçimi kalmasın.
  Future<void> _release(int address) async {
    try {
      await serial.sendAndReceive(
        CommandBuilder.buildManagementCommand(addressIndex: address, row: 0),
        timeout: _probeTimeout,
      );
    } catch (_) {}
  }
}
