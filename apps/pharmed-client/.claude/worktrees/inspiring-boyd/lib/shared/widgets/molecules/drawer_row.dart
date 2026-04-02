import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// DrawerRow
// [SWREQ-UI-MOL-004] [HAZ-003]
// Kullanım: Kabin görselinde yatay 3'lü çekmece satırı
// Atomlar : 3x DrawerCell
// Kural   : Her zaman tam 3 hücre içerir — assert ile korunur
// Sınıf  : Class B — kabin stok durumunu temsil eder
// ─────────────────────────────────────────────────────────────────

class DrawerRow extends StatelessWidget {
  const DrawerRow({super.key, required this.cells})
    : assert(cells.length == 3, 'DrawerRow tam olarak 3 DrawerCell içermeli');

  final List<DrawerCell> cells;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: cells[0]),
        const SizedBox(width: 5),
        Expanded(child: cells[1]),
        const SizedBox(width: 5),
        Expanded(child: cells[2]),
      ],
    );
  }
}
