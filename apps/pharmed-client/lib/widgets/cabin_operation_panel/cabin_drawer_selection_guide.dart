// [SWREQ-UI-CENSUSGUIDE-001] [IEC 62304 §5.5]
// Sayım seçim ekranında sol tarafta gösterilen, DOKUNULABİLİR çekmece
// listesi. CabinLocationGuide ile KARIŞTIRILMAMALI — o, yürütme anındaki
// DrawerQueueStatus'u (active/completed/failed/pending) gösteren salt
// okunur bir bileşen; bunun hiçbir "seçili mi" kavramı yok. Burada ihtiyaç
// duyulan şey farklı bir state modeli (tri-state seçim) olduğu için ayrı
// bir widget olarak kuruldu.
//
// Her satır bir DrawerGroup'u temsil eder ve üç görsel duruma sahiptir:
//   - Tümü seçili   → dolu checkbox
//   - Kısmi seçili  → çizgili (indeterminate) checkbox
//   - Hiçbiri seçili değil → boş checkbox
// Bir satıra dokunmak o çekmecenin TÜM ilaçlarını toggle eder.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum DrawerSelectionState { none, partial, all }

class CabinDrawerSelectionGuide extends StatelessWidget {
  const CabinDrawerSelectionGuide({
    super.key,
    required this.groups,
    required this.assignments,
    required this.selectedUnitIds,
    required this.onToggleDrawer,
    this.title = 'KABİN GENEL BAKIŞ',
  });

  /// Kabindeki tüm fiziksel çekmeceler.
  final List<DrawerGroup> groups;

  /// Kabindeki tüm ilaç atamaları — bir DrawerGroup'un ilaçlarını bulmak
  /// için group.units'teki id'lerle assignment.cabinDrawerId eşleştirilir.
  final List<MedicineAssignment> assignments;

  final Set<int> selectedUnitIds;
  final ValueChanged<DrawerGroup> onToggleDrawer;
  final String title;

  /// Bu çekmeceye ait tüm ilaçların unit (cabinDrawerId) kimlikleri.
  List<int> _unitIdsFor(DrawerGroup group) {
    final unitIdsInGroup = group.units.map((u) => u.id).whereType<int>().toSet();
    return assignments
        .where((a) => a.cabinDrawerId != null && unitIdsInGroup.contains(a.cabinDrawerId))
        .map((a) => a.cabinDrawerId!)
        .toList();
  }

  DrawerSelectionState _stateFor(List<int> unitIds) {
    if (unitIds.isEmpty) return DrawerSelectionState.none;
    final selectedCount = unitIds.where(selectedUnitIds.contains).length;
    if (selectedCount == 0) return DrawerSelectionState.none;
    if (selectedCount == unitIds.length) return DrawerSelectionState.all;
    return DrawerSelectionState.partial;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.lgAll,
        boxShadow: MedShadows.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: groups.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, i) {
                  final group = groups[i];
                  final unitIds = _unitIdsFor(group);
                  return _DrawerSelectionRow(
                    group: group,
                    state: _stateFor(unitIds),
                    onTap: unitIds.isEmpty ? null : () => onToggleDrawer(group),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSelectionRow extends StatelessWidget {
  const _DrawerSelectionRow({required this.group, required this.state, required this.onTap});

  final DrawerGroup group;
  final DrawerSelectionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = state != DrawerSelectionState.none;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: MedRadius.mdAll,
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? MedColors.blueLight : MedColors.surface,
            border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: isSelected ? 1.5 : 1),
            borderRadius: MedRadius.mdAll,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(group.name, style: MedTextStyles.monoMd(color: MedColors.text3)),
              ),
              const SizedBox(width: 8),
              MedCheckbox(
                value: state != DrawerSelectionState.none,
                onChanged: (_) {},
                partial: state == DrawerSelectionState.partial,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
