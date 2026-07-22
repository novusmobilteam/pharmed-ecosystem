// Kabin işlem kartlarında (dolum, sayım, iade...) ortak stok seviyesi
// kavramı. Önceden MedCellInputCard'ın içindeydi; kart kabuğu (MedCellInputCard)
// artık kullanılmıyor ama bu küçük sınıflandırma+renk eşlemesi her işlem
// tipinin kendi kartında tekrar tekrar yazılmasın diye burada kalıyor.

import 'dart:ui';

import 'package:pharmed_ui/pharmed_ui.dart';

enum MedCellStockLevel { ok, low, critical }

extension MedCellStockLevelColorX on MedCellStockLevel {
  Color get color => switch (this) {
    MedCellStockLevel.ok => MedColors.green,
    MedCellStockLevel.low => MedColors.amber,
    MedCellStockLevel.critical => MedColors.red,
  };
}
