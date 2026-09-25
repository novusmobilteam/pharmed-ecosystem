import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../core/mixins/mixins.dart';
import 'cabin_operation_execution.dart';

/// Kübik / birim doz ayrımını, göz etiketini ve SKT kurallarını tek yerde
/// toplar. Ekranlar yalnızca işleme özgü olanı (etiketler, SKT modu) verir.
class CabinOperationEntryBody extends StatelessWidget {
  const CabinOperationEntryBody({
    super.key,
    required this.job,
    required this.target,
    required this.handlers,
    required this.isPerCellMiadEnabled,
    this.drawerGroup,
    this.enabled = true,
  });

  final CabinOperationDrawerJob job;
  final CabinOperationTarget target;
  final CabinEntryHandlers handlers;
  final DrawerGroup? drawerGroup;
  final bool isPerCellMiadEnabled;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final mode = target.mode;
    final countLabel = mode.countLabel(context);
    final secondaryLabel = mode.secondaryLabel(context);

    if (target.mode == CabinOperationMode.intake) {
      return CabinIntakeEntryList(target: target, handlers: handlers, drawerGroup: drawerGroup, enabled: enabled);
    }

    if (job.isKubik) {
      final units = drawerGroup?.units ?? const [];
      final visualUnits = kubikUnitsInVisualOrder(units, columnCount: 4);
      final unitIndex = visualUnits.indexWhere((u) => u.id == target.assignment.drawerUnit?.id);
      return CabinCubicEntryCard(
        target: target,
        cellLabel: unitIndex >= 0 ? cubicCellLabel(unitIndex) : '-',
        cellNumber: unitIndex >= 0 ? unitIndex + 1 : job.targets.indexOf(target) + 1,
        cellCount: units.isNotEmpty ? units.length : job.targets.length,
        enabled: enabled,
        countLabel: countLabel,
        onCountChanged: countLabel != null ? handlers.onCubicCountChanged : null,
        secondaryLabel: secondaryLabel,
        onSecondaryChanged: secondaryLabel != null ? handlers.onCubicSecondaryChanged : null,
        onMiadChanged: handlers.onCubicMiadChanged,
        miadRequired: target.hasEntry,
      );
    }

    return CabinUnitDoseEntryTable(
      target: target,
      enabled: enabled,
      miadMode: !mode.requiresMiad
          ? CabinEntryMiadMode.hidden
          : (isPerCellMiadEnabled ? CabinEntryMiadMode.perCell : CabinEntryMiadMode.shared),
      countLabel: countLabel,
      onCountChanged: countLabel != null ? handlers.onStepCountChanged : null,
      secondaryLabel: secondaryLabel,
      onSecondaryChanged: secondaryLabel != null ? handlers.onStepSecondaryChanged : null,
      onCellMiadChanged: handlers.onStepMiadChanged,
      onSharedMiadChanged: handlers.onSingleMiadChanged,
    );
  }
}
