// [SWREQ-CLI-MINTAKE-013] [IEC 62304 §5.5]
// Alımın giriş görünümü: planın her gözü için bir kart — "bu gözden şu kadar
// al, gözdeki miktarı say". Kübikte tek kart (aktif kapak), birim dozda
// plandaki her göz ayrı kart. Alınacak miktar plandan gelir ve salt
// okunurdur; sayım ilacın sayım tipine göre gösterilir.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../core/mixins/mixins.dart';
import 'cabin_operation_execution.dart';

class CabinIntakeEntryList extends StatelessWidget {
  const CabinIntakeEntryList({
    super.key,
    required this.target,
    required this.handlers,
    this.drawerGroup,
    this.enabled = true,
  });

  final CabinOperationTarget target;
  final CabinEntryHandlers handlers;
  final DrawerGroup? drawerGroup;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cells = target.isKubik ? [_kubikCell()] : _unitDoseCells();

    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.55,
        child: ListView.separated(
          itemCount: cells.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _IntakeCellCard(target: target, cell: cells[i]),
        ),
      ),
    );
  }

  _IntakeCell _kubikCell() {
    final units = drawerGroup?.units ?? const <DrawerUnit>[];
    final visualUnits = kubikUnitsInVisualOrder(units, columnCount: 4);
    final unitIndex = visualUnits.indexWhere((u) => u.id == target.assignment.drawerUnit?.id);

    return _IntakeCell(
      label: unitIndex >= 0 ? cubicCellLabel(unitIndex) : '-',
      take: target.cubicSecondary,
      count: target.cubicCount,
      recorded: target.currentQuantity,
      onCountChanged: handlers.onCubicCountChanged,
    );
  }

  List<_IntakeCell> _unitDoseCells() => [
    for (var i = 0; i < target.steps.length; i++)
      if (target.isStepActive(i))
        _IntakeCell(
          label: '${i + 1}',
          take: target.steps[i].secondaryQuantity ?? 0,
          count: target.steps[i].countQuantity,
          recorded: target.steps[i].recordedQuantity,
          onCountChanged: (v) => handlers.onStepCountChanged(i, v),
        ),
  ];
}

class _IntakeCell {
  const _IntakeCell({
    required this.label,
    required this.take,
    required this.count,
    required this.recorded,
    required this.onCountChanged,
  });

  final String label;
  final double take;
  final double? count;
  final double recorded;
  final ValueChanged<double> onCountChanged;
}

class _IntakeCellCard extends StatelessWidget {
  const _IntakeCellCard({required this.target, required this.cell});

  final CabinOperationTarget target;
  final _IntakeCell cell;

  @override
  Widget build(BuildContext context) {
    final isBlind = target.countType == CountType.blindCount;
    final isMissing = isBlind && cell.count == null;

    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: isMissing ? MedColors.amber : MedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.smAll),
                child: Text(
                  context.l10n.cabinEntryCard_cellBadge(cell.label),
                  style: MedTextStyles.monoMd(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          IntrinsicHeight(
            child: Row(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _TakeBox(target: target, take: cell.take),
                ),
                if (target.showsCount)
                  Expanded(
                    flex: 2,
                    child: _CountBox(
                      count: cell.count,
                      recorded: cell.recorded,
                      // Kör sayımda kayıttaki miktar HİÇBİR yerde gösterilmez.
                      revealRecorded: !isBlind,
                      onChanged: cell.onCountChanged,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bu gözden alınacak miktar — plandan, salt okunur.
class _TakeBox extends StatelessWidget {
  const _TakeBox({required this.target, required this.take});

  final CabinOperationTarget target;
  final double take;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: MedColors.blueLight,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.blue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 6,
        children: [
          Text(
            context.l10n.cabinEntry_takeLabel.toUpperCase(),
            style: MedTextStyles.bodySm(color: MedColors.blue, weight: FontWeight.w600),
          ),
          Text(
            target.assignment.quantityLabel(take),
            style: MedTextStyles.titleLg(color: MedColors.blue).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Gözdeki miktarın sayımı — normal sayımda kayıtla dolu gelir, kör sayımda
/// boş başlar ve girilmesi zorunludur.
class _CountBox extends StatelessWidget {
  const _CountBox({required this.count, required this.recorded, required this.revealRecorded, required this.onChanged});

  final double? count;
  final double recorded;
  final bool revealRecorded;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = count;

    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            context.l10n.refill_label_countQty.toUpperCase(),
            style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600),
          ),
          CabinQuantityStepper(value: current, onChanged: onChanged, large: true, allowEmpty: true),
        ],
      ),
    );
  }
}
