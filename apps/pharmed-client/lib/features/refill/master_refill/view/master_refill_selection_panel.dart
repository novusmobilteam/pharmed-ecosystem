// [SWREQ-CLI-MREFILL-005] [IEC 62304 §5.5]
// FAZ 1 — Dolum yapılacak gözlerin seçildiği tam-ekran panel.
//
// HMI tek-iş prensibi: bu panel yalnızca Selection fazında, tek başına
// tam ekran gösterilir. Yürütme başlayınca view Execution panel'e geçer;
// bu panel artık "kilitli" durum taşımaz.
//
// Gözler medicine.id bazında gruplanır (API her gözü ayrı MedicineAssignment
// olarak döndürür). Kart grid; her göz kendi stoğu (mevcut/maks + doluluk +
// min/kritik/maks eşikleri) ile gösterilir, tek dokunuşla seçilir/çıkarılır.
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
    final notifier = ref.read(masterRefillNotifierProvider.notifier);

    final selection = switch (state) {
      MasterRefillSelection s => s,
      MasterRefillError(previousState: MasterRefillSelection s) => s,
      _ => null,
    };
    if (selection == null) return const SizedBox.shrink();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1300),
        alignment: Alignment.center,
        padding: MedSpacing.insetXl * 2,
        decoration: BoxDecoration(boxShadow: MedShadows.md, color: MedColors.surface, borderRadius: MedRadius.lgAll),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(),
            const SizedBox(height: 18),
            _SearchField(value: selection.search, onChanged: notifier.onSearchChanged),
            const SizedBox(height: 18),
            Expanded(
              child: selection.visibleMedicines.isEmpty
                  ? EmptyStateWidget(title: context.l10n.refill_hint_noMedicines)
                  : _SlotGrid(selection: selection, notifier: notifier),
            ),
            const SizedBox(height: 16),
            _StartBar(
              selectedCount: selection.selectedCount,
              canStart: selection.canStart,
              onStart: notifier.startAutoRefill,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Başlık ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(context.l10n.refill_title_selectMedicines, style: MedTextStyles.titleXl()),
        Text(context.l10n.refill_hint_selectSlots, style: MedTextStyles.bodyMd(color: MedColors.text3)),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: MedTextInputField(
        initialValue: value,
        hintText: context.l10n.refill_hint_searchMedicine,
        prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), color: MedColors.text3),
        onChanged: (v) => onChanged(v ?? ''),
      ),
    );
  }
}

// ── Göz grid'i (medicine.id bazında sıralı, düz göz kartları) ───────────────────

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({required this.selection, required this.notifier});

  final MasterRefillSelection selection;
  final MasterRefillNotifier notifier;

  @override
  Widget build(BuildContext context) {
    // Gözleri medicine.id sırasını koruyarak düz listeye aç.
    final ordered = <MedicineAssignment>[];
    final seen = <int>{};
    for (final a in selection.visibleMedicines) {
      final mid = a.medicine?.id;
      if (mid == null) continue;
      if (!seen.contains(mid)) {
        seen.add(mid);
        ordered.addAll(selection.visibleMedicines.where((x) => x.medicine?.id == mid));
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const targetWidth = 300.0;
        const gap = 14.0;
        final columns = (constraints.maxWidth / (targetWidth + gap)).floor().clamp(1, 4);
        final cardWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return SingleChildScrollView(
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: ordered.map((a) {
              final id = a.cabinDrawerId;
              return SizedBox(
                width: cardWidth,
                child: _SlotCard(
                  assignment: a,
                  selected: id != null && selection.selectedUnitIds.contains(id),
                  onTap: id == null ? null : () => notifier.toggleUnit(id),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// ── Göz kartı ──────────────────────────────────────────────────────────────────

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.assignment, required this.selected, required this.onTap});

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
    String statusLabel = context.l10n.refill_status_stockOk;
    Color statusBg = MedColors.greenLight;
    if (current <= critQty) {
      stockColor = MedColors.red;
      statusLabel = context.l10n.refill_status_stockCritical;
      statusBg = MedColors.redLight;
    } else if (current <= minQty) {
      stockColor = MedColors.amber;
      statusLabel = context.l10n.refill_status_stockLow;
      statusBg = MedColors.amberLight;
    }

    final addressLabel = isKubik
        ? context.l10n.refill_chip_drawerCell(address, '${cellNo ?? '-'}')
        : context.l10n.refill_chip_drawer(address);

    final pct = maxQty > 0 ? (current / maxQty).clamp(0.0, 1.0) : 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.xl2All,
      child: Container(
        padding: MedSpacing.insetXl,
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: selected ? MedColors.blue : MedColors.border, width: selected ? 2 : 1),
          borderRadius: MedRadius.xl2All,
          boxShadow: MedShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            // İlaç adı + adres + checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        assignment.medicine?.name ?? '—',
                        style: MedTextStyles.titleSm(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(addressLabel, style: MedTextStyles.monoXs(color: MedColors.text3)),
                    ],
                  ),
                ),
                _CheckBox(checked: selected),
              ],
            ),
            // Durum rozeti + mevcut/maks
            Row(
              spacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusBg, borderRadius: MedRadius.smAll),
                  child: Text(statusLabel, style: MedTextStyles.monoXs(color: stockColor)),
                ),
                const Spacer(),
                Text(
                  '${current.formatFractional} / ${maxQty.formatFractional}',
                  style: MedTextStyles.monoSm(color: MedColors.text2),
                ),
              ],
            ),
            // Doluluk + eşik işaretleri
            _StockBar(pct: pct, minPct: _ratio(minQty, maxQty), critPct: _ratio(critQty, maxQty), color: stockColor),
          ],
        ),
      ),
    );
  }

  double _ratio(double v, double max) => max > 0 ? (v / max).clamp(0.0, 1.0) : 0.0;
}

// ── Doluluk çubuğu + min/kritik işaretleri ─────────────────────────────────────

class _StockBar extends StatelessWidget {
  const _StockBar({required this.pct, required this.minPct, required this.critPct, required this.color});

  final double pct;
  final double minPct;
  final double critPct;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
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
              Positioned(
                left: w * minPct - 1,
                top: 0,
                child: _Tick(color: MedColors.text4),
              ),
              Positioned(
                left: w * critPct - 1,
                top: 0,
                child: _Tick(color: MedColors.red),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 2, height: 14, color: color);
  }
}

// ── Checkbox ─────────────────────────────────────────────────────────────────

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: checked ? MedColors.blue : MedColors.surface,
        border: Border.all(color: checked ? MedColors.blue : MedColors.border, width: 2),
        borderRadius: MedRadius.mdAll,
      ),
      child: checked ? Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), size: 15, color: MedColors.surface) : null,
    );
  }
}

// ── Alt başlat çubuğu ──────────────────────────────────────────────────────────

class _StartBar extends StatelessWidget {
  const _StartBar({required this.selectedCount, required this.canStart, required this.onStart});

  final int selectedCount;
  final bool canStart;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.refill_label_selectedCount(selectedCount),
            style: MedTextStyles.bodyMd(color: MedColors.text2),
          ),
          MedButton(
            label: context.l10n.refill_action_startAuto,
            size: MedButtonSize.lg,
            onPressed: canStart ? onStart : null,
          ),
        ],
      ),
    );
  }
}
