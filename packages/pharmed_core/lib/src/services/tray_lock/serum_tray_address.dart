// [SWREQ-HW-TRAY-002] [IEC 62304 §5.5]
// Serum avadanlığının kilit kartı adresi (kart ID + port) — yerleşimden türetilir.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Elektromanyetik kilitli bir raftaki avadanlığın donanım adresi.
final class SerumTrayAddress {
  const SerumTrayAddress({required this.deviceId, required this.port, required this.cellId});

  /// Rafın kilit kartı ID'si (`<iXX:…>` içindeki XX).
  final int deviceId;

  /// Avadanlığın kart üzerindeki portu (1-8).
  final int port;

  /// Avadanlığın DrawerCell.id'si — log ve eşleştirme için.
  final int cellId;

  /// [cellId]'li avadanlığın adresini serum yerleşiminden çözer.
  ///
  /// Avadanlık bulunamazsa ya da rafı kilitli DEĞİLSE null döner — kilitsiz
  /// rafta kilit kartı yoktur, çağıran taraf yalnızca serum kapağıyla ilerler.
  ///
  /// EŞLEME KURALLARI (backend port dönmediği sürece yerleşimden hesaplanır):
  ///   - deviceId = raf sırası (orderNo; Raf 1 en üst → kart 01)
  ///   - port     = avadanlığın kapladığı EN SAĞDAKİ alanın numarası;
  ///                alanlar sağdan sola 1..8 numaralanır.
  ///     Örn. sağdan sola [büyük, orta, küçük] → portlar 1, 5, 7.
  static SerumTrayAddress? resolve({required List<SerumShelfLayout> shelves, required int cellId}) {
    for (final shelf in shelves) {
      var areaOffset = 0;
      for (final tray in shelf.trays) {
        if (tray.id == cellId) {
          if (!shelf.isLocked) return null;
          return SerumTrayAddress(deviceId: shelf.orderNo, port: areaOffset + 1, cellId: cellId);
        }
        areaOffset += tray.size.areaSize;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SerumTrayAddress && other.deviceId == deviceId && other.port == port && other.cellId == cellId;

  @override
  int get hashCode => Object.hash(deviceId, port, cellId);

  @override
  String toString() => 'SerumTrayAddress(device: $deviceId, port: $port, cell: $cellId)';
}
