// Kübik kart / göz adreslemesi ve yoklaması (#259, #267).
//
// Kübik çekmecede çekmece kartı (master) standart tip cevabı verir (`.01,`),
// bu yüzden 16 ve 20 gözlü kübik aynı görünür. Gözleri kübik kartları
// (sıra kartları, slave) açar.
//
// Komut: `:Zkattc;`
//   a  = SIRA KARTI no (1–9)       — sahada eski test uygulamasıyla doğrulandı
//   tt = o karttaki GÖZ no (01–99) — `00` geçerli göz değildir (`hz` döner)
//   c  = (ASCII('Z') + ASCII(k) + a + tt) % 10
//
// Eski yorum (a = göz 1–4, tt = slave 00–04) yanlıştı: 5. sıra kartı (`a=5`)
// hiç sorgulanmadığı için 20 gözlü kübik 16 görünüyordu. `pharmed_core`'daki
// `CommandBuilder.buildCubicCommand` hâlâ a 1–4 / tt 0–4 ile sınırlı; hw-test
// sahada doğrulanana kadar kübik komutlarını burada üretir ve gönderir.
// Client tarafı doğrulamadan sonra güncellenecek.
//
// Yoklama (eski test uygulamasının yöntemi, göz bazında genişletilmiş):
//   1) tt=01 ile a=1…8: cevap veren sıra kartları
//   2) her mevcut kart için tt=01…08: cevap veren gözler
// `hz`: master o karttan 250 ms içinde cevap alamadı (kart / göz yok).
//
// Satır seçimini bırakmak çağıranın işidir.

import 'package:pharmed_core/pharmed_core.dart';

/// Kübik gözün adresi: [card] = sıra kartı (`a`, 1–9), [lid] = o karttaki
/// göz (`tt`, 01–99).
typedef CubicLidAddress = ({int card, int lid});

/// Yoklanan en büyük sıra kartı ve kart başına göz numarası.
/// Kart üst sınırı `DrawerAddress.port` (1–8) ile uyumlu tutulur.
const cubicMaxCard = 8;
const cubicMaxLid = 8;

/// `:Zkattc;` — sınır denetimi yalnızca alan genişliği kadardır (a tek hane,
/// tt iki hane); anlamlı aralık sahada yoklamayla bulunur.
String buildCubicFrame(DeviceAction action, {required int card, required int lid}) {
  if (card < 1 || card > 9) throw ArgumentError('Kübik sıra kartı 1–9 arasında olmalı');
  if (lid < 0 || lid > 99) throw ArgumentError('Kübik göz 00–99 arasında olmalı');
  final checksum = ('Z'.codeUnitAt(0) + action.code.codeUnitAt(0) + card + lid) % 10;
  return ':Z${action.code}$card${lid.toString().padLeft(2, '0')}$checksum;';
}

/// Kübik yoklamasının sonucu.
class CubicProbe {
  const CubicProbe({required this.cards, required this.lids, required this.raw});

  /// `tt=01` yoklamasında `ok` dönen sıra kartları.
  final List<int> cards;

  /// `ok` dönen gözler (kart, sonra göz sırasıyla).
  final List<CubicLidAddress> lids;

  /// Bütün ham cevaplar: (kart, göz) → cevap (`null` = cevap yok).
  final Map<CubicLidAddress, String?> raw;

  /// Kart başına göz sayısı.
  Map<int, int> get lidsPerCard => {
    for (final c in cards) c: lids.where((l) => l.card == c).length,
  };
}

/// Yoklama; her cevapta [onResponse] çağrılır (canlı tablo için).
Future<CubicProbe> probeCubic(
  ICabinOperationService ops, {
  required int address,
  required int row,
  void Function(CubicLidAddress at, String? response)? onResponse,
}) async {
  final manager = ManagementCard(addressIndex: address);
  final raw = <CubicLidAddress, String?>{};

  Future<bool> ping(int card, int lid) async {
    final at = (card: card, lid: lid);
    if (raw.containsKey(at)) return raw[at]?.contains('ok') ?? false;
    String? response;
    try {
      response = await ops.sendRawCommand(
        manager: manager,
        targetRow: row,
        commandPayload: buildCubicFrame(DeviceAction.ping, card: card, lid: lid),
      );
    } catch (_) {}
    response = response?.trim();
    raw[at] = response;
    onResponse?.call(at, response);
    return response?.contains('ok') ?? false;
  }

  // 1) Sıra kartları: tt=01.
  final cards = <int>[];
  for (var card = 1; card <= cubicMaxCard; card++) {
    if (await ping(card, 1)) cards.add(card);
  }

  // 2) Her kartın gözleri: tt=01…08.
  final lids = <CubicLidAddress>[];
  for (final card in cards) {
    for (var lid = 1; lid <= cubicMaxLid; lid++) {
      if (await ping(card, lid)) lids.add((card: card, lid: lid));
    }
  }
  return CubicProbe(cards: cards, lids: lids, raw: raw);
}

/// Rapor için özet: "20 göz · 5 sıra kartı (1: 4, 2: 4, 3: 4, 4: 4, 5: 4)".
String describeCubicProbe(CubicProbe probe) {
  if (probe.cards.isEmpty) {
    final sample = probe.raw[(card: 1, lid: 1)];
    return 'hiçbir sıra kartı cevap vermedi (kart 1 · göz 01: ${sample ?? 'cevap yok'})';
  }
  final per = probe.lidsPerCard.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  return '${probe.lids.length} göz · ${probe.cards.length} sıra kartı ($per)';
}

/// Kübik gözü açar (`:ZO…;`). Başarısızsa [CubicLidException] fırlatır.
Future<void> openCubicLid(
  ICabinOperationService ops, {
  required ManagementCard manager,
  required int row,
  required int card,
  required int lid,
}) async {
  final response = await ops.sendRawCommand(
    manager: manager,
    targetRow: row,
    commandPayload: buildCubicFrame(DeviceAction.open, card: card, lid: lid),
  );
  final failure = switch (response) {
    null => CubicLidFailure.noResponse,
    final r when r.contains('ht') => CubicLidFailure.drawerNotOpen,
    final r when r.contains('hz') => CubicLidFailure.slaveNoResponse,
    final r when r.contains('ok') => null,
    _ => CubicLidFailure.protocolError,
  };
  if (failure != null) throw CubicLidException(failure, detail: response);
  // Kübik mekanik hareket için bekleme (client ile aynı).
  await Future<void>.delayed(const Duration(milliseconds: 150));
}

/// Kübik göz durumu (`:ZS…;` → `ac` / `kp`).
Future<CubicLidStatus> cubicLidStatus(
  ICabinOperationService ops, {
  required ManagementCard manager,
  required int row,
  required int card,
  required int lid,
}) async {
  try {
    final response = await ops.sendRawCommand(
      manager: manager,
      targetRow: row,
      commandPayload: buildCubicFrame(DeviceAction.status, card: card, lid: lid),
    );
    if (response == null) return CubicLidStatus.unknown;
    if (response.contains('ac')) return CubicLidStatus.open;
    if (response.contains('kp')) return CubicLidStatus.closed;
    return CubicLidStatus.unknown;
  } catch (_) {
    return CubicLidStatus.unknown;
  }
}

/// Client'ın `streamMasterCubicLidStatus` davranışıyla aynı: art arda 6
/// bilinmeyen cevapta `timeoutError`.
Stream<CubicLidStatus> streamCubicLidStatus(
  ICabinOperationService ops, {
  required ManagementCard manager,
  required int row,
  required int card,
  required int lid,
}) async* {
  const maxConsecutiveFailures = 6;
  var failures = 0;
  while (true) {
    final status = await cubicLidStatus(ops, manager: manager, row: row, card: card, lid: lid);
    if (status == CubicLidStatus.unknown) {
      failures++;
      if (failures >= maxConsecutiveFailures) {
        failures = 0;
        yield CubicLidStatus.timeoutError;
      } else {
        yield CubicLidStatus.unknown;
      }
    } else {
      failures = 0;
      yield status;
    }
    await Future<void>.delayed(DeviceConstants.statusPollingInterval);
  }
}
