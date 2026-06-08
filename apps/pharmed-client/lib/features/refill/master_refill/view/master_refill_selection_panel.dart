// [SWREQ-CLI-MREFILL-005] [IEC 62304 §5.5]
// FAZ 1 — Dolum yapılacak ilaçların ve gözlerin seçildiği panel.
//
// İlaçlar medicine.id bazında gruplanır (API her gözü ayrı MedicineAssignment
// olarak döndürür). Her ilaç kartı altında o ilacın atandığı gözler chip olarak
// listelenir; chip'ler default seçili gelir, kullanıcı tek tek çıkarabilir.
//
// Her gözün kendi stoğu ayrı gösterilir (kullanıcı az stoklu göze öncelik
// verebilsin diye).
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../notifier/master_refill_notifier.dart';
import '../notifier/master_refill_state.dart';

class MasterRefillSelectionPanel extends ConsumerWidget {
  const MasterRefillSelectionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterRefillNotifierProvider);
    if (state is! MasterRefillSelection) return const SizedBox.shrink();

    final notifier = ref.read(masterRefillNotifierProvider.notifier);

    // İlaçları medicine.id bazında grupla (sıra korunur).
    final groups = <int, List<MedicineAssignment>>{};
    for (final a in state.visibleMedicines) {
      final mid = a.medicine?.id;
      if (mid == null) continue;
      groups.putIfAbsent(mid, () => []).add(a);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(selectedCount: state.selectedCount),
        const SizedBox(height: 12),
        _SearchField(value: state.search, onChanged: notifier.onSearchChanged),
        const SizedBox(height: 12),
        Expanded(
          child: groups.isEmpty
              ? _EmptyHint(message: context.l10n.refill_hint_noMedicines)
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: groups.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final units = groups.values.elementAt(index);
                    return _MedicineCard(
                      units: units,
                      selectedUnitIds: state.selectedUnitIds,
                      onToggleMedicine: notifier.toggleMedicine,
                      onToggleUnit: notifier.toggleUnit,
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        _StartBar(canStart: state.canStart, onStart: notifier.startAutoRefill),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.selectedCount});

  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(context.l10n.refill_title_selectMedicines, style: MedTextStyles.titleMd())),
        if (selectedCount > 0)
          Text(
            context.l10n.refill_label_selectedCount(selectedCount),
            style: MedTextStyles.monoSm(color: MedColors.blue),
          ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return MedTextInputField(
      initialValue: value,
      hintText: context.l10n.refill_hint_searchMedicine,
      prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), size: 18, color: MedColors.text3),
      onChanged: (v) => onChanged(v ?? ''),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({
    required this.units,
    required this.selectedUnitIds,
    required this.onToggleMedicine,
    required this.onToggleUnit,
  });

  /// Aynı ilaca ait gözler (her biri ayrı MedicineAssignment).
  final List<MedicineAssignment> units;
  final Set<int> selectedUnitIds;
  final ValueChanged<int> onToggleMedicine;
  final ValueChanged<int> onToggleUnit;

  @override
  Widget build(BuildContext context) {
    final first = units.first;
    final medicine = first.medicine;
    final medicineId = medicine?.id ?? 0;

    final unitIds = units.map((u) => u.cabinDrawerId).whereType<int>().toSet();
    final anySelected = unitIds.any(selectedUnitIds.contains);
    final allSelected = unitIds.isNotEmpty && unitIds.every(selectedUnitIds.contains);

    // Toplam stok (tüm gözler) — adet gösterim.
    final totalStock = units.fold<double>(0, (sum, u) => sum + u.toDisplayQuantity(u.totalQuantity));
    final maxStock = units.fold<double>(0, (sum, u) => sum + u.maxQuantityFromBackend);

    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: anySelected ? MedColors.blue : MedColors.border, width: anySelected ? 2 : 1),
        borderRadius: MedRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => onToggleMedicine(medicineId),
            borderRadius: MedRadius.lgAll,
            child: Padding(
              padding: MedSpacing.insetMd,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  _CheckBox(checked: allSelected, partial: anySelected && !allSelected),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          medicine?.name ?? '—',
                          style: MedTextStyles.titleMd(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (medicine?.barcode != null)
                          Text(medicine!.barcode!, style: MedTextStyles.monoMd(color: MedColors.text3)),
                      ],
                    ),
                  ),
                  _StockSummary(total: totalStock, max: maxStock, unitCount: units.length),
                ],
              ),
            ),
          ),
          if (anySelected) ...[
            Divider(height: 1, color: MedColors.border2),
            Padding(
              padding: MedSpacing.insetMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(context.l10n.refill_label_targetCells, style: MedTextStyles.bodySm(color: MedColors.text3)),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Büyük dokunmatik ekran: kart genişliği ~260px hedefli,
                      // sığan kadar kolon. En az 1.
                      const targetWidth = 260.0;
                      const gap = 8.0;
                      final columns = (constraints.maxWidth / (targetWidth + gap)).floor().clamp(1, 4);
                      final cardWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;

                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: units.map((u) {
                          final id = u.cabinDrawerId;
                          return SizedBox(
                            width: 260,
                            child: _CellChip(
                              assignment: u,
                              selected: id != null && selectedUnitIds.contains(id),
                              onTap: id == null ? null : () => onToggleUnit(id),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CellChip extends StatelessWidget {
  const _CellChip({required this.assignment, required this.selected, required this.onTap});

  final MedicineAssignment assignment;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final slot = assignment.drawerUnit?.drawerSlot;
    final cellNo = assignment.drawerUnit?.orderNo ?? assignment.drawerUnit?.compartmentNo;
    final address = slot?.address ?? '?';
    final isKubik = assignment.isKubikType;

    final current = assignment.toDisplayQuantity(assignment.totalQuantity);
    final maxQty = assignment.maxQuantityFromBackend;
    final critQty = assignment.critQuantityFromBackend;
    final minQty = assignment.minQuantityFromBackend;

    Color stockColor = MedColors.green;
    if (current <= critQty) {
      stockColor = MedColors.red;
    } else if (current <= minQty) {
      stockColor = MedColors.amber;
    }

    final label = isKubik
        ? context.l10n.refill_chip_drawerCell(address, '${cellNo ?? '-'}')
        : context.l10n.refill_chip_drawer(address);

    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.mdAll,
      child: Container(
        padding: MedSpacing.insetMd,
        decoration: BoxDecoration(
          color: selected ? MedColors.blueLight : MedColors.surface2,
          border: Border.all(color: selected ? MedColors.blue : MedColors.border, width: selected ? 1.5 : 1),
          borderRadius: MedRadius.mdAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            // Başlık: seçim ikonu + göz adresi + mevcut/maks
            Row(
              spacing: 6,
              children: [
                Icon(
                  selected ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill) : PhosphorIcons.circle(),
                  size: 16,
                  color: selected ? MedColors.blue : MedColors.text4,
                ),
                Expanded(
                  child: Text(
                    label,
                    style: MedTextStyles.bodyMd(
                      color: selected ? MedColors.blue : MedColors.text,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${current.formatFractional} / ${maxQty.formatFractional}',
                  style: MedTextStyles.monoMd(color: stockColor),
                ),
              ],
            ),
            // Doluluk çubuğu
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: maxQty > 0 ? (current / maxQty).clamp(0.0, 1.0) : 0,
                minHeight: 6,
                backgroundColor: MedColors.border2,
                valueColor: AlwaysStoppedAnimation(stockColor),
              ),
            ),
            // Min / Kritik / Maks
            Row(
              spacing: 6,
              children: [
                _ThresholdBadge(
                  label: context.l10n.refill_label_min,
                  value: minQty.formatFractional,
                  color: MedColors.text2,
                ),
                _ThresholdBadge(
                  label: context.l10n.refill_label_critical,
                  value: critQty.formatFractional,
                  color: MedColors.red,
                ),
                _ThresholdBadge(
                  label: context.l10n.refill_label_max,
                  value: maxQty.formatFractional,
                  color: MedColors.text2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThresholdBadge extends StatelessWidget {
  const _ThresholdBadge({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: MedColors.surface, borderRadius: MedRadius.smAll),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(label, style: MedTextStyles.monoMd(color: MedColors.text4)),
            Text(value, style: MedTextStyles.monoMd(color: color)),
          ],
        ),
      ),
    );
  }
}

class _StockSummary extends StatelessWidget {
  const _StockSummary({required this.total, required this.max, required this.unitCount});

  final double total;
  final double max;
  final int unitCount;

  @override
  Widget build(BuildContext context) {
    Color color = MedColors.green;
    final ratio = max > 0 ? total / max : 0.0;
    if (ratio <= 0.25) {
      color = MedColors.red;
    } else if (ratio <= 0.5) {
      color = MedColors.amber;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 5,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Text('${total.toInt()} / ${max.toInt()}', style: MedTextStyles.bodyMd(color: color)),
            SizedBox(
              width: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: MedColors.border2,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
          ],
        ),
        Text(context.l10n.refill_label_cellCount(unitCount), style: MedTextStyles.monoMd(color: MedColors.text3)),
      ],
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.checked, required this.partial});

  final bool checked;
  final bool partial;

  @override
  Widget build(BuildContext context) {
    final active = checked || partial;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: active ? MedColors.blue : MedColors.surface,
        border: Border.all(color: active ? MedColors.blue : MedColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: active
          ? Icon(
              partial ? PhosphorIcons.minus(PhosphorIconsStyle.bold) : PhosphorIcons.check(PhosphorIconsStyle.bold),
              size: 13,
              color: MedColors.surface,
            )
          : null,
    );
  }
}

class _StartBar extends StatelessWidget {
  const _StartBar({required this.canStart, required this.onStart});

  final bool canStart;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            spacing: 6,
            children: [
              Icon(PhosphorIcons.info(), size: 15, color: MedColors.text3),
              Expanded(
                child: Text(
                  context.l10n.refill_hint_autoQueueOrder,
                  style: MedTextStyles.bodySm(color: MedColors.text3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        MedButton(
          label: context.l10n.refill_action_startAuto,
          //icon: PhosphorIcons.play(),
          onPressed: canStart ? onStart : null,
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Icon(PhosphorIcons.pill(), size: 36, color: MedColors.text4),
          Text(
            message,
            style: MedTextStyles.bodySm(color: MedColors.text3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
