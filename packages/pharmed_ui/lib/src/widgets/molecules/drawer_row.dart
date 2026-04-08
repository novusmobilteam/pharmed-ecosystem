import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// DrawerRow
// [SWREQ-UI-MOL-004] [HAZ-003]
// Kullanım: Kabin görselinde yatay 3'lü çekmece satırı
// Atomlar : 3x DrawerCell
// Kural   : Her zaman tam 3 hücre içerir — assert ile korunur
// Sınıf  : Class B — kabin stok durumunu temsil eder
// ─────────────────────────────────────────────────────────────────

class DrawerRow extends StatelessWidget {
  const DrawerRow({super.key, required this.cells}) : assert(cells.length > 0, 'DrawerRow en az 1 DrawerCell içermeli');

  final List<dynamic> cells;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < cells.length; i++) ...[
          Expanded(child: cells[i]),
          if (i < cells.length - 1) const SizedBox(width: 5),
        ],
      ],
    );
  }
}
