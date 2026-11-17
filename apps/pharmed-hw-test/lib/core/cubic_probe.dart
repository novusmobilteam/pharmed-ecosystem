// Kübik kapak yoklaması (#259).
//
// Kübik çekmecede iki tür kart vardır: çekmece kartı (master) standart tip
// cevabı verir (ör. `.01,`), bu yüzden 16 ve 20 gözlü kübik aynı görünür.
// Kapakları açan kübik kartları (slave, sıra 00–04) her biri en fazla 4 göz
// (port 1–4) taşır; göz sayısı `Z M` (orada mısın?) ile cevap veren
// kapaklardan çıkarılır. Eski test uygulaması da böyle sayar.
//
// `hz` cevabı: master o slave'den 250 ms içinde cevap alamadı (slave yok ya
// da arızalı). Bütün portları `hz` dönen sıra raporda ayrıca belirtilir
// (#267): 20 gözlü kübikte 5. slave'in sorunu böyle görünür.
//
// Satır seçimini bırakmak çağıranın işidir.

import 'package:pharmed_core/pharmed_core.dart';

/// Cevap veren kübik kapağın adresi: [index] = kübik sıra (slave, 00–04),
/// [port] = o slave'deki göz (1–4).
typedef CubicLidAddress = ({int index, int port});

/// Kübik yoklamasının sonucu: cevap veren kapaklar ve `ok` olmayan ham
/// cevaplar (sıra → port → cevap; `null` = cevap yok).
class CubicProbe {
  const CubicProbe({required this.lids, required this.other});

  final List<CubicLidAddress> lids;

  /// `ok` dışındaki cevaplar: sıra → (port → ham cevap ya da `null`).
  final Map<int, Map<int, String?>> other;

  /// Bütün portları `hz` dönen sıralar: master o sıradaki slave'den 250 ms
  /// içinde cevap alamadı (#267).
  List<int> get silentSlaves => [
    for (final e in other.entries)
      if (e.value.length == 4 && e.value.values.every((r) => r != null && r.contains('hz'))) e.key,
  ]..sort();
}

/// Kübik kapakları sıra 00–04 × port 1–4 olarak yoklar.
Future<CubicProbe> probeCubic(
  ICabinOperationService ops, {
  required int address,
  required int row,
}) async {
  final manager = ManagementCard(addressIndex: address);
  final lids = <CubicLidAddress>[];
  final other = <int, Map<int, String?>>{};
  for (var index = 0; index <= 4; index++) {
    for (var port = 1; port <= 4; port++) {
      String? response;
      try {
        response = await ops.sendRawCommand(
          manager: manager,
          targetRow: row,
          commandPayload: CommandBuilder.buildCubicCommand(action: DeviceAction.ping, port: port, row: index),
        );
      } catch (_) {}
      if (response != null && response.contains('ok')) {
        lids.add((index: index, port: port));
      } else {
        (other[index] ??= {})[port] = response?.trim();
      }
    }
  }
  return CubicProbe(lids: lids, other: other);
}

/// Cevap veren kapakları sıra, sonra port düzeninde döner.
Future<List<CubicLidAddress>> probeCubicLidAddresses(
  ICabinOperationService ops, {
  required int address,
  required int row,
}) async => (await probeCubic(ops, address: address, row: row)).lids;

String _two(int i) => i.toString().padLeft(2, '0');

/// Rapor için özet: "16 kapak · sıra 01 (4), … · sıra 00: slave cevap vermedi (hz ×4)".
String describeCubicProbe(CubicProbe probe) {
  final lids = probe.lids;
  final parts = <String>[];
  if (lids.isEmpty) {
    parts.add('hiçbir kapak cevap vermedi');
  } else {
    final perSlave = <int, int>{};
    for (final l in lids) {
      perSlave[l.index] = (perSlave[l.index] ?? 0) + 1;
    }
    final slaves = (perSlave.keys.toList()..sort()).map((i) => '${_two(i)} (${perSlave[i]})').join(', ');
    parts.add('${lids.length} kapak · sıra $slaves');
  }
  final silent = probe.silentSlaves;
  for (final i in silent) {
    parts.add('sıra ${_two(i)}: slave cevap vermedi (hz ×4)');
  }
  for (final e in (probe.other.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))) {
    if (silent.contains(e.key)) continue;
    final detail = (e.value.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
        .map((p) => 'port ${p.key}: ${p.value ?? 'cevap yok'}')
        .join(', ');
    parts.add('sıra ${_two(e.key)}: $detail');
  }
  return parts.join(' · ');
}
