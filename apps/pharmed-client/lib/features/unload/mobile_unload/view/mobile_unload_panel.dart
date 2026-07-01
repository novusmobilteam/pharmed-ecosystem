import 'package:flutter/material.dart';
import 'package:pharmed_client/widgets/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/enums/cabin_operation_mode.dart';
import '../../unload.dart';

class MobileUnloadPanel extends StatelessWidget {
  const MobileUnloadPanel({
    super.key,
    required this.notifier,
    required this.state,
    required this.drawerStage,
    required this.onStartUnload,
    required this.onCompleteUnload,
    required this.onReopenDrawer,
    required this.onSelectAssignment,
    required this.onChangePatient,
    required this.onCancelUnload,
  });

  final MobileUnloadNotifier notifier;
  final MobileUnloadState state;
  final MobileDrawerStage drawerStage;
  final VoidCallback onStartUnload;
  final VoidCallback onCompleteUnload;
  final VoidCallback onReopenDrawer;
  final ValueChanged<BedAssignment> onSelectAssignment;
  final VoidCallback onChangePatient;
  final VoidCallback onCancelUnload;

  bool get _isProcessActive => drawerStage.isActive;

  @override
  Widget build(BuildContext context) {
    return OperationPanelBase(
      mode: CabinOperationMode.unload,
      child: switch (state) {
        MobileUnloadUninitialized() ||
        MobileUnloadLoading() => const Center(child: CircularProgressIndicator(strokeWidth: 2)),

        MobileUnloadIdle() ||
        MobileUnloadSlotSelected() ||
        MobileUnloadNoPatient() ||
        MobileUnloadRollbackCompleted() ||
        MobileUnloadFatalError() => CabinPatientPickerList(
          assignments: state.availableAssignments,
          onSelected: onSelectAssignment,
        ),

        _ when state.readyContext != null => _buildReady(context, notifier, state.readyContext!),

        _ => throw StateError('Unhandled MobileUnloadState: $state'),
      },
    );
  }

  Widget _buildReady(BuildContext context, MobileUnloadNotifier notifier, MobileUnloadReady ready) {
    final hasUnloadableItems = ready.prescriptionItems.any(
      (i) => i.id != null && i.status == PrescriptionMovementType.purchasePending,
    );

    return Column(
      spacing: 8.0,
      children: [
        CabinActivePatientCard(
          patient: ready.patient,
          bed: ready.bed,
          room: ready.room,
          onChange: _isProcessActive ? null : onChangePatient,
        ),
        if (!_isProcessActive) ...[
          MedFilterChipGroup<PrescriptionMovementType?>(
            options: [null, ...PrescriptionMovementType.intakeableTypes],
            selected: ready.statusFilter,
            onChanged: notifier.onStatusFilterChanged,
            labelBuilder: (type) => type?.label ?? context.l10n.filter_all,
            bgColor: ready.statusFilter?.backgroundColor,
          ),
          MedFilterChipGroup<DateRangePreset>(
            options: DateRangePreset.values,
            selected: ready.datePreset,
            labelBuilder: (p) => p.label(context.l10n),
            onChanged: notifier.onDatePresetChanged,
          ),
        ],
        Expanded(child: _UnloadPrescriptionList(items: ready.prescriptionItems)),
        _UnloadActionBar(drawerStage: drawerStage, onStart: onStartUnload, hasUnloadableItems: hasUnloadableItems),
      ],
    );
  }
}

class _UnloadPrescriptionList extends StatelessWidget {
  const _UnloadPrescriptionList({required this.items});

  final List<PrescriptionItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPrescription);
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 6, bottom: 6, right: 2),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return RxOperationCard(
          mode: RxOperationCardMode.unload,
          item: items[index],
          isSelected: false,
          rfidStatus: null,
          isEligible: false,
          onTap: () {},
        );
      },
    );
  }
}

class _UnloadActionBar extends StatelessWidget {
  const _UnloadActionBar({required this.drawerStage, required this.onStart, required this.hasUnloadableItems});

  final MobileDrawerStage drawerStage;
  final VoidCallback onStart;
  final bool hasUnloadableItems;

  @override
  Widget build(BuildContext context) {
    // İşlem aktifken (çekmece açık/kapalı) asıl kontrol dialog'da.
    // Panel action bar yalnızca Idle'da "Başlat" ve iptal gösterir.
    return Row(
      children: [
        if (drawerStage is MobileDrawerIdle && hasUnloadableItems) ...[
          Expanded(
            child: MedButton(label: context.l10n.unload_action_start, size: MedButtonSize.sm, onPressed: onStart),
          ),
        ] else
          const Spacer(),
      ],
    );
  }
}
