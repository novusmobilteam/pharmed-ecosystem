// [SWREQ-SCAN-003] [IEC 62304 §5.5]
// Kübik çekmecenin göz yapısını karttan yoklar (#275).
//
// Kübik çekmece kartı (master) tip sorgusuna 16 ve 20 gözlüde aynı cevabı
// verir (`.01,`); göz sayısı yalnızca kapakları açan sıra kartlarının
// (slave) `Z M` (orada mısın?) cevaplarından çıkarılabilir:
//   1) tt=01 ile a=1…[maxCard]: cevap veren sıra kartları
//   2) her mevcut kart için tt=01…[maxLid]: cevap veren gözler (ilk
//      cevapsız gözde o kart biter)
// `[ok]` → var, `[hz]` (master 250 ms içinde slave'den cevap alamadı) ya
// da cevapsızlık → yok. Yöntem eski test uygulaması ve hw-test ile sahada
// doğrulandı (#267).
//
// Satır seçimini bırakmak çağıranın işidir.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Yoklama sonucu: cevap veren gözler (kart, sonra göz sırasıyla).
class CubicProbeResult {
  const CubicProbeResult({required this.cards, required this.lids});

  /// `tt=01` yoklamasında cevap veren sıra kartları.
  final List<int> cards;

  /// Cevap veren gözler: (card = a, lid = tt).
  final List<({int card, int lid})> lids;

  int get lidCount => lids.length;

  /// Log için kart başına göz sayısı: {1: 4, 2: 4, …}.
  Map<int, int> get lidsPerCard => {for (final c in cards) c: lids.where((l) => l.card == c).length};
}

/// [manager] yönetim kartında [row] satırındaki kübik çekmeceyi yoklar.
Future<CubicProbeResult> probeCubicLids(
  ICabinOperationService ops, {
  required ManagementCard manager,
  required int row,
  int maxCard = 8,
  int maxLid = 8,
}) async {
  Future<bool> ping(int card, int lid) async {
    try {
      final response = await ops.sendRawCommand(
        manager: manager,
        targetRow: row,
        commandPayload: CommandBuilder.buildCubicCommand(action: DeviceAction.ping, port: card, row: lid),
      );
      return response != null && response.contains('ok');
    } catch (_) {
      return false;
    }
  }

  final cards = <int>[];
  for (var card = 1; card <= maxCard; card++) {
    if (await ping(card, 1)) cards.add(card);
  }

  // Gözler bir kartta 01'den başlayıp ardışıktır; ilk cevapsız gözde o
  // kartın yoklaması biter (tarama süresini kısaltır — hw-test teşhis için
  // hepsini yoklar).
  final lids = <({int card, int lid})>[];
  for (final card in cards) {
    for (var lid = 1; lid <= maxLid; lid++) {
      if (!await ping(card, lid)) break;
      lids.add((card: card, lid: lid));
    }
  }
  return CubicProbeResult(cards: cards, lids: lids);
}
