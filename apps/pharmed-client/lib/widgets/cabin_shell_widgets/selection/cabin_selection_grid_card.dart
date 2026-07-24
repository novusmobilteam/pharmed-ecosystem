// Master kabin seçim ekranlarının (dolum, sayım...) ortak seçilebilir kart'ı.
// MasterRefillSelectionPanel'deki _SlotCard/_StockBar/_CheckBox/_Tick'ten
// çıkarıldı. addressLabel/statusLabel ÇÖZÜLMÜŞ string olarak geliyor —
// l10n key'leri işlemler arası farklı olabileceği için (refill_status_stockOk
// vs ileride count_status_...) çözümleme çağıranda kalıyor, tıpkı
// CabinDrawerOpeningView'daki title/subtitle deseninde olduğu gibi.

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class CabinSelectionGridCard extends StatelessWidget {
  const CabinSelectionGridCard({
    super.key,
    required this.title,
    required this.addressLabel,
    required this.current,
    required this.maxQty,
    required this.minQty,
    required this.critQty,
    required this.statusLabel,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final String addressLabel;
  final double current;
  final double maxQty;
  final double minQty;
  final double critQty;

  /// "Normal" / "Düşük" / "Kritik" gibi zaten çözülmüş metin — hangi
  /// eşiğe göre gösterileceğini kart kendisi ([_level]) belirliyor.
  final String statusLabel;

  final bool selected;
  final VoidCallback? onTap;

  MedCellStockLevel get _level => current <= critQty
      ? MedCellStockLevel.critical
      : (current <= minQty ? MedCellStockLevel.low : MedCellStockLevel.ok);

  Color get _statusBg => switch (_level) {
    MedCellStockLevel.ok => MedColors.greenLight,
    MedCellStockLevel.low => MedColors.amberLight,
    MedCellStockLevel.critical => MedColors.redLight,
  };

  double _ratio(double v, double max) => max > 0 ? (v / max).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final color = _level.color;
    final pct = _ratio(current, maxQty);

    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.xl2All,
      child: Container(
        padding: MedSpacing.insetXl,
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: selected ? MedColors.blue : MedColors.border, width: selected ? 2 : 1),
          borderRadius: MedRadius.midAll,
          boxShadow: MedShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(title, style: MedTextStyles.titleMd(), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(addressLabel, style: MedTextStyles.bodyMd(color: MedColors.text3)),
                    ],
                  ),
                ),
                MedCheckbox(value: selected, onChanged: (_) => onTap!(), size: MedCheckboxSize.md),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _statusBg, borderRadius: MedRadius.smAll),
                  child: Text(statusLabel, style: MedTextStyles.monoSm(color: color)),
                ),
                const Spacer(),
                Text(
                  '${current.formatFractional} / ${maxQty.formatFractional}',
                  style: MedTextStyles.monoSm(color: MedColors.text2),
                ),
              ],
            ),
            _StockBar(pct: pct, minPct: _ratio(minQty, maxQty), critPct: _ratio(critQty, maxQty), color: color),
          ],
        ),
      ),
    );
  }
}

class _StockBar extends StatelessWidget {
  const _StockBar({required this.pct, required this.minPct, required this.critPct, required this.color});

  final double pct;
  final double minPct;
  final double critPct;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 10,
                backgroundColor: MedColors.surface2,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          Align(
            // w*critPct yerine [-1, 1] aralığında yüzdesel konum;
            // LayoutBuilder gerektirmediği için IntrinsicHeight altında güvenli.
            alignment: Alignment(_toAlignX(critPct), 0),
            child: const _Tick(color: MedColors.red),
          ),
        ],
      ),
    );
  }

  double _toAlignX(double t) => (2 * t - 1).clamp(-1.0, 1.0);
}

class _Tick extends StatelessWidget {
  const _Tick({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 4, height: 14, color: color);
  }
}
