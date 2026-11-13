// Client'ın bu bilgisayarda tuttuğu kabin tanımını SALT OKUNUR okur.
//
// Client Hive kutularını kullanıcının Belgeler klasöründe tutar
// (`Hive.initFlutter()`, alt klasörsüz). Client açıkken aynı Hive dosyasını
// ikinci bir uygulamanın açması güvenli değildir (kilit, bozulma riski).
// Bu yüzden:
//   1. Gereken .hive dosyaları geçici bir klasöre KOPYALANIR,
//   2. kopyalar farklı kutu adlarıyla açılıp okunur, kapatılır,
//   3. geçici klasör silinir.
// Client'ın dosyaları hiçbir zaman açılmaz ve yazılmaz.

import 'dart:convert';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import 'cabin_model.dart';

class ClientCacheResult {
  const ClientCacheResult({
    required this.snapshot,
    required this.folder,
    this.deviceMode,
    this.comPort,
    this.stationId,
    this.stationName,
    this.savedAt,
    this.notes = const [],
    this.cameras = const [],
    this.printer,
  });

  /// Tanımdaki kabinler (bu bilgisayarın istasyonu).
  final CabinSnapshot snapshot;

  /// Okunan klasör (rapor ve ekranda gösterilir).
  final String folder;

  /// Client kurulum modu: 'standard' (İlaç Bazlı) / 'mobile' (Hasta Bazlı).
  final String? deviceMode;

  /// Client'ın kayıtlı COM portu.
  final String? comPort;
  final int? stationId;
  final String? stationName;

  /// Kabin listesinin client'ta son kaydedildiği zaman.
  final DateTime? savedAt;

  /// Okuma sırasında atlanan / okunamayan kısımlar.
  final List<String> notes;

  /// Client'ta tanımlı kameralar (şifreler güvenli depoda; okunmaz).
  final List<CameraDevice> cameras;

  /// Client'ın fiş yazıcı ayarı.
  final PrinterConfig? printer;

  bool get isMobileSetup => deviceMode == 'mobile';
}

class ClientCacheReader {
  static const _settingsBox = 'app_settings';
  static const _cabinBox = 'cabin_cache';
  static const _slotBox = 'drawer_slot_cache';
  static const _metaBox = 'cabin_meta_cache';
  static const _unitBox = 'drawer_unit_cache';
  static const _cameraBox = 'camera_devices';

  /// Kopyalar bu önekle açılır; test uygulamasının kendi kutularıyla çakışmaz.
  static const _prefix = 'hwtest_client_';

  /// Client'ın Hive klasörü (Belgeler). Bulunamazsa null.
  Future<Directory?> clientFolder() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return null;
    }
  }

  /// Tanım bulunamazsa null döner. Hata fırlatmaz; okunamayan kısımlar
  /// [ClientCacheResult.notes] içinde raporlanır.
  Future<ClientCacheResult?> read() async {
    final folder = await clientFolder();
    if (folder == null) return null;
    if (!File(_path(folder.path, _cabinBox)).existsSync()) return null;

    final temp = await Directory.systemTemp.createTemp('pharmed_hwtest_cache_');
    final opened = <Box<dynamic>>[];
    final notes = <String>[];
    try {
      Future<Box<dynamic>?> open(String name) async {
        final source = File(_path(folder.path, name));
        if (!source.existsSync()) return null;
        try {
          await source.copy(_path(temp.path, '$_prefix$name'));
          final box = await Hive.openBox<dynamic>('$_prefix$name', path: temp.path);
          opened.add(box);
          return box;
        } catch (e) {
          notes.add('$name okunamadı: $e');
          return null;
        }
      }

      final settings = await open(_settingsBox);
      final cabinBox = await open(_cabinBox);
      final slotBox = await open(_slotBox);
      final metaBox = await open(_metaBox);
      final unitBox = await open(_unitBox);
      final cameraBox = await open(_cameraBox);
      if (cabinBox == null) return null;

      final stationId = _asInt(settings?.get('current_station_id'));
      final printerTarget = settings?.get('printer_target') as String?;
      final printer = printerTarget == null || printerTarget.trim().isEmpty
          ? null
          : PrinterConfig(
              connectionType: PrinterConnectionType.values
                      .where((t) => t.name == settings?.get('printer_connection'))
                      .firstOrNull ??
                  PrinterConnectionType.serial,
              target: printerTarget,
              baudRate: _asInt(settings?.get('printer_baud')) ?? PrinterConfig.defaultBaudRate,
            );
      final cameras = <CameraDevice>[];
      for (final raw in cameraBox?.values ?? const <Object?>[]) {
        try {
          final j = jsonDecode('$raw') as Map<String, Object?>;
          cameras.add(
            CameraDevice(
              id: j['id']! as String,
              name: j['name']! as String,
              host: j['host']! as String,
              username: j['username']! as String,
              cabinIds: (j['cabinIds'] as List<Object?>? ?? const []).cast<int>().toSet(),
              rtspPort: (j['rtspPort'] as int?) ?? 554,
              channel: (j['channel'] as int?) ?? 101,
              enabled: (j['enabled'] as bool?) ?? true,
            ),
          );
        } catch (e) {
          notes.add('Kamera tanımı çözülemedi: $e');
        }
      }
      final deviceMode = settings?.get('device_mode') as String?;
      final comPort = settings?.get('com_port') as String?;

      final allCabins = _decodeList(cabinBox.get('cabins'), CabinDTO.fromJson, notes, 'kabin listesi')
          .map(const CabinMapper().toEntity)
          .toList();
      final savedAt = DateTime.tryParse('${cabinBox.get('cabins_saved_at') ?? ''}');

      // Yalnızca bu bilgisayarın istasyonundaki kabinler.
      final cabins = stationId == null
          ? allCabins
          : allCabins.where((c) => _asInt(c.stationId ?? c.station?.id) == stationId).toList();

      final configs = _decodeList(metaBox?.get('drawer_configs'), DrawerConfigDTO.fromJson, notes, 'çekmece tanımları')
          .map(const DrawerConfigMapper().toEntity)
          .toList();
      final types = _decodeList(metaBox?.get('drawer_types'), DrawerTypeDTO.fromJson, notes, 'çekmece tipleri')
          .map(const DrawerTypeMapper().toEntity)
          .toList();
      final configById = {for (final c in configs) if (c.id != null) c.id!: c};
      final typeById = {for (final t in types) if (t.id != null) t.id!: t};

      final infos = <CabinInfo>[];
      for (final cabin in cabins) {
        final address = ManagementCard.indexFromAddressChar(cabin.no);
        if (address == null || cabin.id == null) {
          notes.add('${cabin.name ?? 'Kabin ${cabin.id}'}: adres harfi yok, atlandı');
          continue;
        }

        if (cabin.type == CabinType.mobile) {
          final drawers = _decodeList(
            slotBox?.get('mobile_drawers_${cabin.id}'),
            MobileDrawerSlotDTO.fromJson,
            notes,
            '${cabin.no} mobil çekmeceleri',
          ).map(const MobileDrawerSlotMapper().toEntity).toList()..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
          infos.add(
            CabinInfo(
              addressIndex: address,
              kind: CabinKind.mobile,
              name: cabin.name,
              rfidEnabled: cabin.isRfidEnabled ?? false,
              rfidHost: cabin.rfidIp,
              rfidPort: int.tryParse(cabin.rfidPort ?? ''),
              units: [
                for (final d in drawers)
                  CabinUnit(
                    row: DeviceConstants.serumSlaveRow,
                    kind: UnitKind.mobile,
                    name: 'Mobil çekmece ${d.orderNumber}',
                    port: d.orderNumber,
                  ),
              ],
            ),
          );
          continue;
        }

        final slots = _decodeList(slotBox?.get('slots_${cabin.id}'), DrawerSlotDTO.fromJson, notes, '${cabin.no} çekmeceleri')
            .map(const DrawerSlotMapper().toEntity)
            .toList();
        final units = <CabinUnit>[];
        for (final slot in slots) {
          final row = int.tryParse(slot.address ?? '');
          if (row == null) continue;
          final config = slot.drawerConfig ?? configById[slot.drawerConfigId];
          final type = config?.drawerType ?? typeById[config?.drawerTypeId];
          final resolvedConfig = config == null || config.drawerType != null || type == null
              ? config
              : config.copyWith(drawerType: type);
          final cells = slot.id == null
              ? const <DrawerUnit>[]
              : (_decodeList(unitBox?.get('units_${slot.id}'), DrawerUnitDTO.fromJson, notes, 'satır $row gözleri')
                    .map(const DrawerUnitMapper().toEntity)
                    .toList());
          if (config?.isSerum ?? false) {
            final isLid = address != 1 && row == DeviceConstants.serumSlaveRow;
            units.add(CabinRules.serumUnit(row: row, lidNo: isLid ? slot.orderNumber : null, slotId: slot.id));
          } else {
            units.add(
              CabinUnit(
                row: row,
                kind: CabinRules.drawerKind(type),
                name: CabinRules.drawerName(type),
                compartmentCount: type?.compartmentCount,
                typeNo: config?.deviceTypeNo,
                problem: config == null ? 'Çekmece tanımı bulunamadı' : null,
                slotId: slot.id,
                config: resolvedConfig,
                cells: cells,
              ),
            );
          }
        }
        units.sort((a, b) => a.row != b.row ? a.row.compareTo(b.row) : (a.lidNo ?? 0).compareTo(b.lidNo ?? 0));
        final (kind, visible) = CabinRules.classify(addressIndex: address, units: units);
        infos.add(
          CabinInfo(
            addressIndex: address,
            kind: kind,
            units: visible,
            name: cabin.name,
            rfidEnabled: cabin.isRfidEnabled ?? false,
            rfidHost: cabin.rfidIp,
            rfidPort: int.tryParse(cabin.rfidPort ?? ''),
          ),
        );
      }
      infos.sort((a, b) => a.addressIndex.compareTo(b.addressIndex));

      if (infos.isEmpty) return null;
      return ClientCacheResult(
        snapshot: CabinSnapshot(source: CabinSource.clientCache, cabins: infos, time: savedAt),
        folder: folder.path,
        deviceMode: deviceMode,
        comPort: comPort,
        stationId: stationId,
        stationName: cabins.map((c) => c.station?.name).whereType<String>().firstOrNull,
        savedAt: savedAt,
        notes: notes,
        cameras: cameras,
        printer: printer,
      );
    } finally {
      for (final box in opened) {
        try {
          await box.close();
        } catch (_) {}
      }
      try {
        await temp.delete(recursive: true);
      } catch (_) {}
    }
  }

  static String _path(String folder, String box) => '$folder${Platform.pathSeparator}$box.hive';

  static int? _asInt(Object? v) => v is int ? v : int.tryParse('${v ?? ''}');

  static List<T> _decodeList<T>(
    Object? raw,
    T Function(Map<String, dynamic>) fromJson,
    List<String> notes,
    String what,
  ) {
    if (raw is! String) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return [for (final e in list) fromJson(Map<String, dynamic>.from(e as Map))];
    } catch (e) {
      notes.add('$what çözülemedi: $e');
      return const [];
    }
  }
}
