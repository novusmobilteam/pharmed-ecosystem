// [SWREQ-UI-CABINOVERVIEW-001] [IEC 62304 §5.5]
//
// Kabin genel bakış ekranlarının TEK giriş noktası. CabinDrawerSelectionGuide,
// CabinLocationGuide ve MobileCabinOverviewPanel'in YERİNE geçer — üçü de
// artık ayrı sınıf değil, bu widget'ın birer factory constructor'ı:
//   - CabinOverviewPanel.selection(...)  → seçim ekranları (dolum/sayım/alım/iade)
//   - CabinOverviewPanel.execution(...)  → yürütme sırasında konum rehberi
//   - CabinOverviewPanel.info(...)       → mobil kabin bilgi/arıza paneli
//
// Domain → MedOverviewRow/MedCabinLocationDetail dönüşümü burada, PRIVATE
// static metotlarda çözülür — dışarıya hiç sızmaz. Çağıran taraf sadece
// kendi ham verisini (groups/items/slots) verir, "row builder" gibi bir
// şey elle çağırmaz.
//
// pharmed_ui'deki MedCabinOverviewPanel tamamen generic kalır (pharmed_core
// bilmez) — bu dosya onun TEK domain-aware sarmalayıcısıdır, bilerek
// pharmed_ui'ye değil buraya (app katmanı) konur.
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'med_cabin_overview_panel.dart';

class CabinOverviewPanel extends StatelessWidget {
  const CabinOverviewPanel._({
    required this.countLabel,
    required this.rows,
    this.focusedRowId,
    this.locationDetail,
    this.footer,
    // ignore: unused_element_parameter
    this.hint,
    this.maxListHeight,
  });

  // ── 1. SEÇİM MODU ────────────────────────────────────────────────────

  factory CabinOverviewPanel.selection({
    required List<DrawerGroup> groups,
    required List<MedicineAssignment> assignments,
    required Set<int> selectedUnitIds,
    required ValueChanged<DrawerGroup> onToggleDrawer,
    String? focusedGroupName,
    Widget? footer,
  }) {
    final rows = groups.map((group) {
      final unitIds = _selectionUnitIdsFor(group, assignments);
      final state = _selectionStateFor(unitIds, selectedUnitIds);
      final isSelected = state != _DrawerSelectionState.none;

      // TODO : Localization
      return MedOverviewRow(
        id: group.name,
        title: group.name,
        subtitle: group.isKubik ? 'Kübik Çekmece' : 'Birim Doz Çekmece',
        segmentCount: group.isKubik ? 1 : group.units.length,
        borderColor: isSelected ? MedColors.blue : MedColors.border,
        backgroundColor: isSelected ? MedColors.blueLight : MedColors.surface,
        borderWidth: isSelected ? 1.5 : 1,
        trailing: MedCheckbox(
          value: state != _DrawerSelectionState.none,
          onChanged: (_) {},
          partial: state == _DrawerSelectionState.partial,
          size: MedCheckboxSize.lg,
        ),
        onTap: unitIds.isEmpty ? null : () => onToggleDrawer(group),
      );
    }).toList();

    final selectedCount = rows.where((r) => r.borderColor == MedColors.blue).length;
    final focusedGroup = groups.where((g) => g.name == focusedGroupName).firstOrNull;

    return CabinOverviewPanel._(
      countLabel: '$selectedCount/${rows.length} çekmece',
      rows: rows,
      focusedRowId: focusedGroupName,
      locationDetail: focusedGroup == null
          ? null
          : MedCabinLocationDetail(
              address: focusedGroup.name,
              typeLabel: focusedGroup.isKubik ? 'KÜBİK' : 'BİRİM DOZ',
              isKubik: focusedGroup.isKubik,
              cellStates: [
                for (final unit in focusedGroup.units)
                  selectedUnitIds.contains(unit.id) ? MedCellState.target : MedCellState.idle,
              ],
              legendItems: const [
                MedLegendItem(color: MedColors.blue, background: MedColors.blueLight, label: 'Hedef bölme'),
              ],
            ),
      footer: footer,
    );
  }

  static List<int> _selectionUnitIdsFor(DrawerGroup group, List<MedicineAssignment> assignments) {
    final unitIdsInGroup = group.units.map((u) => u.id).whereType<int>().toSet();
    return assignments
        .where((a) => a.cabinDrawerId != null && unitIdsInGroup.contains(a.cabinDrawerId))
        .map((a) => a.cabinDrawerId!)
        .toList();
  }

  static _DrawerSelectionState _selectionStateFor(List<int> unitIds, Set<int> selectedUnitIds) {
    if (unitIds.isEmpty) return _DrawerSelectionState.none;
    final selectedCount = unitIds.where(selectedUnitIds.contains).length;
    if (selectedCount == 0) return _DrawerSelectionState.none;
    if (selectedCount == unitIds.length) return _DrawerSelectionState.all;
    return _DrawerSelectionState.partial;
  }

  // ── 2. YÜRÜTME MODU ──────────────────────────────────────────────────

  factory CabinOverviewPanel.execution({required List<DrawerQueueItem> items, required int activeIndex}) {
    final inQueue = items.where((i) => i.isInQueue).length;
    final completed = items.where((i) => i.status == DrawerQueueStatus.completed).length;
    final activeItem = items.firstWhereOrNull((i) => i.status == DrawerQueueStatus.active);

    final rows = items.map((item) {
      final (Color border, Color bg, Color text) = switch (item.status) {
        DrawerQueueStatus.active => (MedColors.blue, MedColors.blueLight, MedColors.blue),
        DrawerQueueStatus.completed => (MedColors.green, MedColors.greenLight, MedColors.text),
        DrawerQueueStatus.failed => (MedColors.red, MedColors.redLight, MedColors.text),
        DrawerQueueStatus.pending => (MedColors.border, MedColors.surface, MedColors.text),
        DrawerQueueStatus.notInQueue => (MedColors.border, MedColors.surface2, MedColors.text3),
      };

      return MedOverviewRow(
        id: item.address,
        title: item.address,
        subtitle: item.isKubik ? 'Kübik Çekmece' : 'Birim Doz Çekmece',
        segmentCount: item.isKubik ? 1 : item.units.length,
        borderColor: border,
        backgroundColor: bg,
        borderWidth: item.status == DrawerQueueStatus.active ? 1.5 : 1,
        textColor: text,
        trailing: _executionStatusIcon(item.status),
      );
    }).toList();

    return CabinOverviewPanel._(
      countLabel: '$completed/$inQueue',
      rows: rows,
      focusedRowId: activeItem?.address,
      locationDetail: activeItem == null ? null : _executionLocationDetail(activeItem),
      maxListHeight: 300,
    );
  }

  static Widget _executionStatusIcon(DrawerQueueStatus status) {
    return switch (status) {
      DrawerQueueStatus.completed => Icon(
        PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
        size: 16,
        color: MedColors.green,
      ),
      DrawerQueueStatus.failed => Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), size: 16, color: MedColors.red),
      DrawerQueueStatus.active => Container(
        width: 20,
        height: 4,
        decoration: BoxDecoration(color: MedColors.blue, borderRadius: BorderRadius.circular(999)),
      ),
      DrawerQueueStatus.notInQueue => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: MedColors.surface2,
          border: Border.all(color: MedColors.border2),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      DrawerQueueStatus.pending => Container(
        width: 20,
        height: 4,
        decoration: BoxDecoration(color: MedColors.border2, borderRadius: BorderRadius.circular(999)),
      ),
    };
  }

  static MedCabinLocationDetail _executionLocationDetail(DrawerQueueItem item) {
    final isReturnJob = item.group.isReturnDrawer;

    if (isReturnJob && item.isKubik) {
      const mergedCount = 4;
      final normalCount = (item.units.length - mergedCount).clamp(0, item.units.length);
      final normalUnits = item.units.sublist(0, normalCount);

      final rawNormalStates = [
        for (int i = 0; i < normalCount; i++)
          item.completedTargetIndexes.contains(i)
              ? MedCellState.completed
              : item.activeTargetIndex == i
              ? MedCellState.active
              : MedCellState.idle,
      ];

      // İade kutulu kübikte normal grid alanı 3 sütun (4. sütun iade kutusuna
      // ayrılmış) — bkz. MasterCabinDrawerPanel._hybridGrid normalCols=3 ve
      // GetCabinVisualizerDataUseCase._buildSlots (aynı ayrım orada da var).
      final normalStates = reorderParallelToVisual(normalUnits, rawNormalStates, columnCount: 3);

      final mergedIndexes = List.generate(mergedCount, (i) => normalCount + i);
      final mergedState = mergedIndexes.any((i) => item.activeTargetIndex == i)
          ? MedCellState.active
          : mergedIndexes.every((i) => item.completedTargetIndexes.contains(i))
          ? MedCellState.completed
          : MedCellState.idle;

      return MedCabinLocationDetail(
        address: item.address,
        typeLabel: 'KÜBİK',
        isKubik: true,
        cellStates: normalStates,
        mergedTrailingState: mergedState,
        mergedTrailingLabel: 'İADE',
        legendItems: const [
          MedLegendItem(color: MedColors.blue, background: MedColors.blueLight, label: 'Şu an dolduruluyor'),
          MedLegendItem(color: MedColors.green, background: MedColors.greenLight, label: 'Tamamlandı'),
          MedLegendItem(color: MedColors.border, background: MedColors.surface, label: 'Sırada'),
        ],
      );
    }

    final rawCellStates = [
      for (int i = 0; i < item.units.length; i++)
        item.completedTargetIndexes.contains(i)
            ? MedCellState.completed
            : item.activeTargetIndex == i
            ? MedCellState.active
            : !item.isInQueue
            ? MedCellState.excluded
            : MedCellState.idle,
    ];

    // SADECE kübikte eksen düzeltmesi uygulanır — birim doz zaten fiziksel
    // olarak tek satır/sütun mantığında (_UnitDoseTopView), transpozisyon
    // riski yok.
    final cellStates = item.isKubik
        ? reorderParallelToVisual(item.units, rawCellStates, columnCount: 4)
        : rawCellStates;

    return MedCabinLocationDetail(
      address: item.address,
      typeLabel: item.isKubik ? 'KÜBİK' : 'BİRİM DOZ',
      isKubik: item.isKubik,
      cellStates: cellStates,
      legendItems: const [
        MedLegendItem(color: MedColors.blue, background: MedColors.blueLight, label: 'Şu an dolduruluyor'),
        MedLegendItem(color: MedColors.green, background: MedColors.greenLight, label: 'Tamamlandı'),
        MedLegendItem(color: MedColors.border, background: MedColors.surface, label: 'Sırada'),
      ],
    );
  }

  // ── 3. BİLGİ / ARIZA MODU ────────────────────────────────────────────

  factory CabinOverviewPanel.info({
    required List<MobileSlotVisual> slots,
    required void Function(MobileSlotVisual slot) onSlotTap,
    int? selectedSlotId,
  }) {
    final rows = slots.map((slot) {
      final isSelected = slot.slotId == selectedSlotId;
      final hasFault = slot.workingStatus != null && slot.workingStatus != CabinWorkingStatus.working;
      final faultColor = hasFault
          ? (slot.workingStatus == CabinWorkingStatus.maintenance ? MedColors.amber : MedColors.red)
          : null;

      return MedOverviewRow(
        id: slot.slotId.toString(),
        title: 'Mobil Çekmece',
        subtitle: '${slot.totalCells} göz',
        segmentCount: slot.rowColumns.take(6).length,
        borderColor: hasFault ? faultColor! : (isSelected ? MedColors.blue : MedColors.border),
        backgroundColor: MedColors.surface,
        borderWidth: isSelected ? 2 : 1.5,
        segmentColorAt: (i) =>
            faultColor?.withAlpha(128) ?? (isSelected ? MedColors.blue.withAlpha(102) : MedColors.border),
        trailing: hasFault
            ? Icon(
                slot.workingStatus == CabinWorkingStatus.maintenance
                    ? Icons.build_circle_outlined
                    : Icons.error_outline_rounded,
                size: 12,
                color: faultColor,
              )
            : null,
        onTap: () => onSlotTap(slot),
      );
    }).toList();

    return CabinOverviewPanel._(
      countLabel: '${slots.length} çekmece',
      rows: rows,
      focusedRowId: selectedSlotId?.toString(),
    );
  }

  // ── Render ────────────────────────────────────────────────────────────

  final String countLabel;
  final List<MedOverviewRow> rows;
  final String? focusedRowId;
  final MedCabinLocationDetail? locationDetail;
  final Widget? footer;
  final String? hint;
  final double? maxListHeight;

  @override
  Widget build(BuildContext context) {
    return MedCabinOverviewPanel(
      title: 'KABİN GENEL BAKIŞ',
      countLabel: countLabel,
      rows: rows,
      focusedRowId: focusedRowId,
      locationDetail: locationDetail,
      footer: footer,
      hint: hint,
      //maxListHeight: maxListHeight,
    );
  }
}

enum _DrawerSelectionState { none, partial, all }
