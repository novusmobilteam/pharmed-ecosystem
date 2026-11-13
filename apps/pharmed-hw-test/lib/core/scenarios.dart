// Test senaryoları: aktif kabin tanımından ve serum tanımından otomatik
// üretilir. Her senaryonun sonucu ayrı tutulur; test listesi, serum ekranı ve
// rapor aynı sonuç kaydını kullanır.
//
// Yalnızca komutu client ile birebir aynı olan senaryolar üretilir:
//   • Kübik çekmece ana kilidi  → openMasterDrawer(DrawerAddress.cubicMaster)
//   • Serum kapağı              → openMasterSerumDrawer(row, port)
//   • Raf kilit kartı / avadanlık akışı → TrayLockProtocol (SerumTrayAddress)
//   • Mobil çekmece             → openMobileDrawer(port)
//   • Isı / nem, akü            → readTempHumidity (satır 50), readBatteryVoltage (satır 49)
// Birim doz göz açma ve kübik kapaklar Master çekmece sayfasında kalır.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import 'cabin_model.dart';
import 'cabin_type.dart';
import 'serum_definition.dart';
import 'test_status.dart';

enum ScenarioKind {
  cubicMainLock('Kübik çekmece ana kilidi', needsObservation: true),
  serumLid('Serum kapağı', needsObservation: true),
  lockCard('Raf kilit kartı', needsObservation: false),
  trayFlow('Avadanlık akış testi', needsObservation: false),
  mobileDrawer('Mobil çekmece', needsObservation: true),
  tempHumidity('Isı / nem sensörü', needsObservation: false),
  battery('Akü gerilimi', needsObservation: false);

  const ScenarioKind(this.label, {required this.needsObservation});

  final String label;

  /// Komut sonrası teknisyenin fiziksel onayı ("Açıldı / Açılmadı") gerekir.
  final bool needsObservation;
}

class TestScenario {
  const TestScenario({
    required this.id,
    required this.kind,
    required this.group,
    required this.title,
    required this.location,
    required this.addressIndex,
    required this.row,
    this.port,
    this.lidPort,
    this.lockCardId,
    this.trayPort,
  });

  final String id;
  final ScenarioKind kind;

  /// Gruplama başlığı ("A · Master kabin").
  final String group;
  final String title;

  /// Teknik konum ("satır 03 · port 1 · göz 00").
  final String location;

  final int addressIndex;
  final int row;

  /// Çekmece / mobil çekmece portu.
  final int? port;

  /// Serum kapağının portu (akış testinde kapak açmak için).
  final int? lidPort;
  final int? lockCardId;
  final int? trayPort;
}

class ScenarioResult {
  ScenarioResult(this.status, {this.detail, DateTime? time}) : time = time ?? DateTime.now();

  final TestStatus status;
  final String? detail;
  final DateTime time;
}

/// Senaryo kimlikleri — serum ekranı ve test listesi aynı kimliği kullanır.
abstract final class ScenarioIds {
  static String cubic(int address, int row) => 'cubic:$address:$row';
  static String serumLid(int address, int lidNo) => 'serumlid:$address:$lidNo';
  static String lockCard(int address, int lidNo, int shelf) => 'lockcard:$address:$lidNo:$shelf';
  static String trayFlow(int address, int lidNo, int shelf, int trayIndex) => 'trayflow:$address:$lidNo:$shelf:$trayIndex';
  static String mobile(int address, int port) => 'mobile:$address:$port';
  static String tempHumidity(int address) => 'sensor:$address:th';
  static String battery(int address) => 'sensor:$address:bat';
}

class ScenarioResultsNotifier extends Notifier<Map<String, ScenarioResult>> {
  @override
  Map<String, ScenarioResult> build() => const {};

  void set(String id, TestStatus status, {String? detail}) =>
      state = {...state, id: ScenarioResult(status, detail: detail)};

  void clear(String id) => state = {...state}..remove(id);

  void clearAll() => state = const {};
}

final scenarioResultsProvider = NotifierProvider<ScenarioResultsNotifier, Map<String, ScenarioResult>>(
  ScenarioResultsNotifier.new,
);

String _two(int v) => v.toString().padLeft(2, '0');

/// Aktif tanımdan senaryo listesi (kabin → birim sırasıyla).
List<TestScenario> buildScenarios({
  required CabinSnapshot? snapshot,
  required Map<int, SerumTargetDef> serum,
  required HwCabinType? cabinType,
}) {
  if (snapshot == null) return const [];
  final list = <TestScenario>[];
  for (final cabin in snapshot.cabins) {
    final group = cabin.title;
    final a = cabin.addressIndex;

    // Sensörler kabin grubunun sonunda.
    void addSensors() {
      list.add(
        TestScenario(
          id: ScenarioIds.tempHumidity(a),
          kind: ScenarioKind.tempHumidity,
          group: group,
          title: 'Isı / nem oku',
          location: 'yönetim kartı ${cabin.letter} · satır 50',
          addressIndex: a,
          row: 50,
        ),
      );
      if (cabin.kind == CabinKind.mobile) {
        list.add(
          TestScenario(
            id: ScenarioIds.battery(a),
            kind: ScenarioKind.battery,
            group: group,
            title: 'Akü gerilimi oku',
            location: 'yönetim kartı ${cabin.letter} · satır 49',
            addressIndex: a,
            row: 49,
          ),
        );
      }
    }

    if (cabinType == HwCabinType.patientBased) {
      if (cabin.kind != CabinKind.mobile) continue;
      for (final u in cabin.units.where((u) => u.port != null)) {
        list.add(
          TestScenario(
            id: ScenarioIds.mobile(a, u.port!),
            kind: ScenarioKind.mobileDrawer,
            group: group,
            title: '${u.name} — aç',
            location: 'satır ${_two(DeviceConstants.serumSlaveRow)} · port ${u.port}',
            addressIndex: a,
            row: DeviceConstants.serumSlaveRow,
            port: u.port,
          ),
        );
      }
      addSensors();
      continue;
    }

    for (final u in cabin.units.where((u) => u.kind == UnitKind.kubik)) {
      final address = DrawerAddress.cubicMaster(u.row);
      list.add(
        TestScenario(
          id: ScenarioIds.cubic(a, u.row),
          kind: ScenarioKind.cubicMainLock,
          group: group,
          title: '${u.name} — ana kilidi aç',
          location: 'satır ${u.rowLabel} · port ${address.port} · göz ${_two(address.index)}',
          addressIndex: a,
          row: u.row,
          port: address.port,
        ),
      );
    }

    final target = serum[a];
    for (final lid in target?.lids ?? const <SerumLidDef>[]) {
      final isCabinet = target!.isCabinet;
      final lidName = isCabinet ? 'Serum kapağı ${lid.lidNo}' : 'Serum bölmesi';
      list.add(
        TestScenario(
          id: ScenarioIds.serumLid(a, lid.lidNo),
          kind: ScenarioKind.serumLid,
          group: group,
          title: '$lidName — aç',
          location: 'satır ${_two(lid.row)} · port ${lid.port}',
          addressIndex: a,
          row: lid.row,
          lidPort: lid.port,
        ),
      );
      for (final shelf in lid.shelves) {
        if (!shelf.isLocked || shelf.isOpenShelf || shelf.trays.isEmpty) continue;
        final card = SerumRules.lockCardId(shelf);
        list.add(
          TestScenario(
            id: ScenarioIds.lockCard(a, lid.lidNo, shelf.orderNo),
            kind: ScenarioKind.lockCard,
            group: group,
            title: '$lidName · Raf ${shelf.orderNo} — kilit kartı cevap veriyor mu',
            location: 'kilit kartı ${_two(card)}',
            addressIndex: a,
            row: lid.row,
            lidPort: lid.port,
            lockCardId: card,
          ),
        );
        final ports = SerumRules.trayPorts(shelf);
        for (var i = 0; i < shelf.trays.length; i++) {
          list.add(
            TestScenario(
              id: ScenarioIds.trayFlow(a, lid.lidNo, shelf.orderNo, i),
              kind: ScenarioKind.trayFlow,
              group: group,
              title:
                  '$lidName · Raf ${shelf.orderNo} · ${SerumRules.sizeLabel(shelf.trays[i].size)} avadanlık — akış testi',
              location: 'kilit kartı ${_two(card)} · port ${ports[i]}',
              addressIndex: a,
              row: lid.row,
              lidPort: lid.port,
              lockCardId: card,
              trayPort: ports[i],
            ),
          );
        }
      }
    }
    addSensors();
  }
  return list;
}
