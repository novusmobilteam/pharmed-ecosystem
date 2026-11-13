// Serum bölmesi / serum kabini tanımı: kapak sayısı, her kapakta 3 raf, raf
// tipi (açık raf / avadanlık), avadanlık boyları ve elektromanyetik kilit.
//
// Tanım YALNIZCA bu oturumda, bellekte tutulur. Client tanımından gelindiyse
// raf yerleşimi servisten salt okunur çekilir (getSerumLayout); kaydetme
// servisi hiç çağrılmaz.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import 'cabin_model.dart';
import 'providers.dart';

class SerumLidDef {
  const SerumLidDef({
    required this.lidNo,
    required this.row,
    required this.port,
    required this.shelves,
    this.slotId,
    this.fromClient = false,
  });

  /// Kapak numarası (master serum bölmesinde 1).
  final int lidNo;

  /// Serum kartının satırı.
  final int row;

  /// Kapağın portu (master'da 1, serum kabininde kapak no).
  final int port;

  /// Her zaman 3 raf; Raf 1 en üstte.
  final List<SerumShelfLayout> shelves;

  /// Client tanımındaki çekmece kaydı (yerleşimi okumak için).
  final int? slotId;

  /// Raf yerleşimi client tanımından (servisten) yüklendi.
  final bool fromClient;

  SerumLidDef copyWith({List<SerumShelfLayout>? shelves, bool? fromClient}) => SerumLidDef(
    lidNo: lidNo,
    row: row,
    port: port,
    shelves: shelves ?? this.shelves,
    slotId: slotId,
    fromClient: fromClient ?? this.fromClient,
  );
}

class SerumTargetDef {
  const SerumTargetDef({
    required this.addressIndex,
    required this.isCabinet,
    required this.row,
    required this.lids,
    this.layoutRequested = false,
  });

  final int addressIndex;

  /// true: serum kabini (kapak sayısı 1–4, teknisyen tanımlar).
  /// false: master kabin içindeki tek serum bölmesi.
  final bool isCabinet;

  /// Serum kartının satırı.
  final int row;

  /// Boşsa serum kabininde kapak sayısı henüz tanımlanmadı.
  final List<SerumLidDef> lids;

  /// Client yerleşimi servisten istendi mi (bir kez).
  final bool layoutRequested;

  String get letter => ManagementCard(addressIndex: addressIndex).addressChar.toUpperCase();

  String get title => isCabinet ? '$letter · Serum kabini' : '$letter · Master kabin serum bölmesi';

  bool get needsLidCount => isCabinet && lids.isEmpty;

  SerumTargetDef copyWith({List<SerumLidDef>? lids, bool? layoutRequested}) => SerumTargetDef(
    addressIndex: addressIndex,
    isCabinet: isCabinet,
    row: row,
    lids: lids ?? this.lids,
    layoutRequested: layoutRequested ?? this.layoutRequested,
  );

  /// Rapor için düz metin.
  List<String> describe() => [
    title,
    if (needsLidCount) '  Kapak sayısı tanımlanmadı',
    for (final lid in lids) ...[
      '  Kapak ${lid.lidNo} (satır ${lid.row.toString().padLeft(2, '0')}, port ${lid.port})'
          '${lid.fromClient ? ' — client yerleşimi' : ''}',
      for (final shelf in lid.shelves) '    ${SerumRules.describeShelf(shelf)}',
    ],
  ];
}

abstract final class SerumRules {
  static String sizeLabel(SerumTraySize size) => switch (size) {
    SerumTraySize.small => 'Küçük',
    SerumTraySize.medium => 'Orta',
    SerumTraySize.large => 'Büyük',
    SerumTraySize.openShelf => 'Açık raf',
  };

  /// Raftaki avadanlıkların kilit portları, [shelf.trays] sırasıyla
  /// (sağdan sola). Client'taki [SerumTrayAddress.resolve] kuralı kullanılır:
  /// kayıtsız avadanlıklara geçici numara verilip adres çözülür.
  static List<int> trayPorts(SerumShelfLayout shelf) {
    if (shelf.isOpenShelf) return const [];
    final numbered = shelf.copyWith(
      lockType: SerumShelfLockType.locked,
      trays: [for (var i = 0; i < shelf.trays.length; i++) SerumTray(id: i + 1, size: shelf.trays[i].size)],
    );
    return [
      for (var i = 0; i < shelf.trays.length; i++)
        SerumTrayAddress.resolve(shelves: [numbered], cellId: i + 1)?.port ?? 0,
    ];
  }

  /// Rafın kilit kartı ID'si (client kuralı: raf sırası).
  static int lockCardId(SerumShelfLayout shelf) => shelf.orderNo;

  static String describeShelf(SerumShelfLayout shelf) {
    if (shelf.isOpenShelf) return 'Raf ${shelf.orderNo}: açık raf';
    if (shelf.trays.isEmpty) return 'Raf ${shelf.orderNo}: avadanlık yok';
    final ports = trayPorts(shelf);
    final trays = [
      for (var i = 0; i < shelf.trays.length; i++)
        '${sizeLabel(shelf.trays[i].size)}${shelf.isLocked ? ' (port ${ports[i]})' : ''}',
    ].join(', ');
    return 'Raf ${shelf.orderNo}: ${shelf.isLocked ? 'kilitli, kart ${lockCardId(shelf).toString().padLeft(2, '0')}' : 'kilitsiz'}'
        ' — sağdan sola: $trays';
  }
}

class SerumDefinitionsNotifier extends Notifier<Map<int, SerumTargetDef>> {
  @override
  Map<int, SerumTargetDef> build() => const {};

  /// Aktif kabin tanımındaki serum bölmelerini / serum kabinlerini ekler.
  /// Mevcut tanımlar (teknisyenin düzenlemeleri) korunur; tanımda artık
  /// olmayan kabinler çıkarılır.
  void syncFrom(CabinSnapshot? snapshot) {
    final next = <int, SerumTargetDef>{};
    for (final cabin in snapshot?.cabins ?? const <CabinInfo>[]) {
      final serumUnits = cabin.units.where((u) => u.kind == UnitKind.serum).toList();
      final existing = state[cabin.addressIndex];
      if (cabin.kind == CabinKind.master && serumUnits.isNotEmpty) {
        final u = serumUnits.first;
        next[cabin.addressIndex] =
            existing ??
            SerumTargetDef(
              addressIndex: cabin.addressIndex,
              isCabinet: false,
              row: u.row,
              lids: [
                SerumLidDef(
                  lidNo: 1,
                  row: u.row,
                  port: serumLidPort(row: u.row, orderNumber: u.lidNo),
                  shelves: SerumShelfLayout.emptyShelves(),
                  slotId: u.slotId,
                ),
              ],
            );
      } else if (cabin.kind == CabinKind.serumCabinet) {
        final lidUnits = serumUnits.where((u) => u.lidNo != null).toList()
          ..sort((a, b) => a.lidNo!.compareTo(b.lidNo!));
        next[cabin.addressIndex] =
            existing ??
            SerumTargetDef(
              addressIndex: cabin.addressIndex,
              isCabinet: true,
              row: DeviceConstants.serumSlaveRow,
              lids: [
                for (final u in lidUnits)
                  SerumLidDef(
                    lidNo: u.lidNo!,
                    row: u.row,
                    port: u.lidNo!,
                    shelves: SerumShelfLayout.emptyShelves(),
                    slotId: u.slotId,
                  ),
              ],
            );
      }
    }
    state = next;
  }

  /// Client tanımından gelen kapakların raf yerleşimini servisten (salt
  /// okunur) çeker. Her kabin için bir kez.
  Future<void> loadClientLayouts(int address) async {
    final target = state[address];
    if (target == null || target.layoutRequested) return;
    _put(target.copyWith(layoutRequested: true));
    final repo = ref.read(cabinRepositoryProvider);
    for (final lid in target.lids) {
      final slotId = lid.slotId;
      if (slotId == null) continue;
      final result = await repo.getSerumLayout(slotId);
      final shelves = result.data;
      if (shelves == null || shelves.isEmpty) continue;
      final current = state[address];
      if (current == null) return;
      _put(
        current.copyWith(
          lids: [
            for (final l in current.lids) l.lidNo == lid.lidNo ? l.copyWith(shelves: shelves, fromClient: true) : l,
          ],
        ),
      );
    }
  }

  /// Serum kabininde kapak sayısı (1–4). Var olan kapakların tanımı korunur.
  void setLidCount(int address, int count) {
    final target = state[address];
    if (target == null || !target.isCabinet) return;
    final n = count.clamp(1, DeviceConstants.maxSerumLids);
    final byNo = {for (final l in target.lids) l.lidNo: l};
    _put(
      target.copyWith(
        lids: [
          for (var lid = 1; lid <= n; lid++)
            byNo[lid] ??
                SerumLidDef(lidNo: lid, row: target.row, port: lid, shelves: SerumShelfLayout.emptyShelves()),
        ],
      ),
    );
  }

  void updateShelf(int address, int lidNo, SerumShelfLayout shelf) {
    final target = state[address];
    if (target == null) return;
    _put(
      target.copyWith(
        lids: [
          for (final l in target.lids)
            l.lidNo == lidNo
                ? l.copyWith(shelves: [for (final s in l.shelves) s.orderNo == shelf.orderNo ? shelf : s])
                : l,
        ],
      ),
    );
  }

  void _put(SerumTargetDef target) => state = {...state, target.addressIndex: target};
}

final serumDefinitionsProvider = NotifierProvider<SerumDefinitionsNotifier, Map<int, SerumTargetDef>>(
  SerumDefinitionsNotifier.new,
);
