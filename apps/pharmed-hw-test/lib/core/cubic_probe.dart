// Kübik kapak yoklaması (#259).
//
// Kübik çekmecede iki tür kart vardır: çekmece kartı (master) standart tip
// cevabı verir (ör. `.01,`), bu yüzden 16 ve 20 gözlü kübik aynı görünür.
// Kapakları açan kübik kartları (slave, sıra 00–04) her biri en fazla 4 göz
// (port 1–4) taşır; göz sayısı `Z M` (orada mısın?) ile cevap veren
// kapaklardan çıkarılır. Eski test uygulaması da böyle sayar.
//
// Satır seçimini bırakmak çağıranın işidir.

import 'package:pharmed_core/pharmed_core.dart';

/// Cevap veren kübik kapağın adresi: [index] = kübik sıra (slave, 00–04),
/// [port] = o slave'deki göz (1–4).
typedef CubicLidAddress = ({int index, int port});

/// Kübik kapakları sıra 00–04 × port 1–4 olarak yoklar; cevap verenleri
/// sıra, sonra port düzeninde döner.
Future<List<CubicLidAddress>> probeCubicLidAddresses(
  ICabinOperationService ops, {
  required int address,
  required int row,
}) async {
  final manager = ManagementCard(addressIndex: address);
  final lids = <CubicLidAddress>[];
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
      if (response != null && response.contains('ok')) lids.add((index: index, port: port));
    }
  }
  return lids;
}

/// Rapor için kısa özet: "20 kapak · sıra 00 (4), 01 (4), …".
String describeCubicProbe(List<CubicLidAddress> lids) {
  if (lids.isEmpty) return 'hiçbir kapak cevap vermedi';
  final perSlave = <int, int>{};
  for (final l in lids) {
    perSlave[l.index] = (perSlave[l.index] ?? 0) + 1;
  }
  final slaves = (perSlave.keys.toList()..sort())
      .map((i) => '${i.toString().padLeft(2, '0')} (${perSlave[i]})')
      .join(', ');
  return '${lids.length} kapak · sıra $slaves';
}
