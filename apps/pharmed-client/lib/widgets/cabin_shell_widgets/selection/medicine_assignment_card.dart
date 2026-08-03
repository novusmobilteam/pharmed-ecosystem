import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

/// Master kabin 'İlaç Dolum', 'İlaç Sayım', 'İlaç Boşaltma' ekranlarında, 'SelectionView'da
/// kabine atanmış ilaçları kullanmak için gösterilen widget.

class MedicineAssignmentCard extends StatelessWidget {
  const MedicineAssignmentCard({
    super.key,
    this.selected = false,
    this.onTap,
    required this.assignment,
    this.isActive = true,
    this.extra = const [],
  });

  final MedicineAssignment assignment;
  final bool selected;
  final VoidCallback? onTap;
  final bool isActive;
  final List<Widget> extra;

  Color get _statusBg => switch (_level) {
    MedCellStockLevel.ok => MedColors.greenLight,
    MedCellStockLevel.low => MedColors.amberLight,
    MedCellStockLevel.critical => MedColors.redLight,
  };

  double _ratio(double v, double max) => max > 0 ? (v / max).clamp(0.0, 1.0) : 0.0;

  DrawerSlot? get _slot => assignment.drawerUnit?.drawerSlot;
  int? get _cellNo => assignment.drawerUnit?.orderNo ?? assignment.drawerUnit?.compartmentNo;
  String get _address => _slot?.address ?? '?';
  bool get _isKubik => assignment.isKubikType;

  double get _current => assignment.toDisplayQuantity(assignment.totalQuantity);
  double get _maxQty => assignment.maxQuantityFromBackend;
  double get _critQty => assignment.critQuantityFromBackend;
  double get _minQty => assignment.minQuantityFromBackend;

  String get _name => assignment.medicine?.name ?? '-';

  MedCellStockLevel get _level => _current <= _critQty
      ? MedCellStockLevel.critical
      : (_current <= _minQty ? MedCellStockLevel.low : MedCellStockLevel.ok);

  @override
  Widget build(BuildContext context) {
    final color = _level.color;
    final pct = _ratio(_current, _maxQty);

    final bool isSelected = isActive == false ? false : selected;

    String addressLabel = _isKubik
        ? context.l10n.refill_chip_drawerCell(_address, '${_cellNo ?? '-'}')
        : context.l10n.refill_chip_drawer(_address);

    String statusLabel = _current <= _critQty
        ? context.l10n.refill_status_stockCritical
        : (_current <= _minQty ? context.l10n.refill_status_stockLow : context.l10n.refill_status_stockOk);

    return Opacity(
      opacity: isActive ? 1.0 : 1,
      child: InkWell(
        onTap: isActive ? onTap : null,
        borderRadius: MedRadius.xl2All,
        child: Container(
          padding: MedSpacing.insetXl,
          decoration: BoxDecoration(
            color: MedColors.surface,
            border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: isSelected ? 2 : 1),
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
                        Text(_name, style: MedTextStyles.titleMd(), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(addressLabel, style: MedTextStyles.bodyMd(color: MedColors.text3)),
                      ],
                    ),
                  ),
                  if (isActive)
                    MedCheckbox(
                      value: isSelected,
                      onChanged: (_) => isActive ? onTap!() : null,
                      size: MedCheckboxSize.md,
                    ),
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
                    '${_current.formatFractional} / ${_maxQty.formatFractional}',
                    style: MedTextStyles.monoSm(color: MedColors.text2),
                  ),
                ],
              ),
              _StockBar(pct: pct, minPct: _ratio(_minQty, _maxQty), critPct: _ratio(_critQty, _maxQty), color: color),
              if (extra.isNotEmpty)
                SizedBox(
                  width: context.width,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: extra),
                ),
            ],
          ),
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
    return Container(width: 2, height: 12, color: color);
  }
}
