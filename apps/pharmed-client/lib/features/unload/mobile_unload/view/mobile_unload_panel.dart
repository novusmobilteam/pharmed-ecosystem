import 'package:flutter/material.dart';
import 'package:pharmed_client/widgets/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
import '../../unload.dart';

class MobileUnloadPanel extends StatelessWidget {
  const MobileUnloadPanel({
    super.key,
    required this.notifier,
    required this.state,
    required this.drawerStage,
    required this.onStartUnload,
    required this.onCompleteUnload,
    required this.onSelectAssignment,
    required this.onChangePatient,
  });

  final MobileUnloadNotifier notifier;
  final MobileUnloadState state;
  final MobileDrawerStage drawerStage;
  final VoidCallback onStartUnload;
  final VoidCallback onCompleteUnload;
  final ValueChanged<BedAssignment> onSelectAssignment;
  final VoidCallback onChangePatient;

  bool get _isProcessActive => drawerStage.isActive;

  @override
  Widget build(BuildContext context) {
    return OperationPanelBase(
      mode: CabinOperationMode.unload,
      child: switch (state) {
        MobileUnloadUninitialized() ||
        MobileUnloadLoading() => const Center(child: CircularProgressIndicator(strokeWidth: 2)),

        MobileUnloadIdle() || MobileUnloadSlotSelected() || MobileUnloadNoPatient() => CabinPatientPickerList(
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
            labelBuilder: (type) => type?.label(context) ?? context.l10n.filter_all,
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
        _UnloadActionBar(
          drawerStage: drawerStage,
          onStart: onStartUnload,
          hasUnloadableItems: hasUnloadableItems,
          baselineCompleted: ready.baselineCompleted,
        ),
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
  const _UnloadActionBar({
    required this.drawerStage,
    required this.hasUnloadableItems,
    required this.baselineCompleted,
    required this.onStart,
  });

  final MobileDrawerStage drawerStage;
  final bool hasUnloadableItems;
  final bool baselineCompleted;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    // Çekmece açılıyor VEYA açıldı ama baseline henüz alınmadı → loading.
    final isOpening = drawerStage is MobileDrawerOpening || (drawerStage is MobileDrawerOpened && !baselineCompleted);

    return switch (drawerStage) {
      // Idle + sayılacak item var → başlat butonu
      MobileDrawerIdle() when hasUnloadableItems => SizedBox(
        width: context.width,
        child: MedButton(
          label: context.l10n.unload_action_start,
          onPressed: onStart,
          isLoading: false,
          size: MedButtonSize.sm,
        ),
      ),

      // Açılıyor / taranıyor → aynı buton ama loading, basılamaz
      MobileDrawerOpening() || MobileDrawerOpened() when isOpening => SizedBox(
        width: context.width,
        child: MedButton(
          label: context.l10n.unload_action_start,
          onPressed: null,
          isLoading: true,
          size: MedButtonSize.sm,
        ),
      ),

      _ => const SizedBox.shrink(),
    };
  }
}
