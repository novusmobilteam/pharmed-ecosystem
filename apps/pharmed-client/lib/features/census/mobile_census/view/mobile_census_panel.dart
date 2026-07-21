import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/providers/providers.dart';
import '../../census.dart';

part 'report_extra_stock_dialog.dart';
part 'rx_census_group_card.dart';

class MobileCensusPanel extends StatelessWidget {
  const MobileCensusPanel({
    super.key,
    required this.notifier,
    required this.state,
    required this.drawerStage,
    required this.onStartCensus,
    required this.onSelectAssignment,
    required this.onChangePatient,
    required this.onToggleItem,
  });

  final MobileCensusNotifier notifier;
  final MobileCensusState state;
  final MobileDrawerStage drawerStage;
  final VoidCallback onStartCensus;

  final ValueChanged<BedAssignment> onSelectAssignment;
  final VoidCallback onChangePatient;
  final ValueChanged<int> onToggleItem;

  /// Süreç aktif (Opening/Opened/Closed) mı?
  bool get _isProcessActive => drawerStage.isActive;

  @override
  Widget build(BuildContext context) {
    return OperationPanelBase(
      mode: CabinOperationMode.census,
      child: switch (state) {
        MobileCensusUninitialized() ||
        MobileCensusLoading() => const Center(child: CircularProgressIndicator(strokeWidth: 2)),

        // Hasta seçilmediği tüm durumlar + kurtarılamaz hata → liste göster
        MobileCensusIdle() || MobileCensusSlotSelected() || MobileCensusNoPatient() || MobileCensusFatalError() =>
          CabinPatientPickerList(assignments: state.availableAssignments, onSelected: onSelectAssignment),

        // ready taşıyan tüm state'ler (Ready/DrawerOpening/Saving/WaitingClose/
        // ClosedEarly/Success/Error) → Ready görünümü
        _ when state.readyContext != null => _buildReady(context, notifier, state.readyContext!),

        _ => throw StateError('Unhandled MobileCensusState: $state'),
      },
    );
  }

  Widget _buildReady(BuildContext context, MobileCensusNotifier notifier, MobileCensusReady ready) {
    return Column(
      spacing: 8.0,
      children: [
        CabinActivePatientCard(
          patient: ready.patient,
          bed: ready.bed,
          room: ready.room,
          onChange: _isProcessActive ? null : onChangePatient,
        ),
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
        Expanded(
          child: _CensusPrescriptionList(items: ready.prescriptionItems, drawerStage: drawerStage),
        ),
        _CensusActionBar(
          drawerStage: drawerStage,
          onStart: onStartCensus,
          hasCountableItems: ready.prescriptionItems.any(
            (i) => i.id != null && i.status == PrescriptionMovementType.purchasePending,
          ),
          baselineCompleted: ready.baselineCompleted,
        ),
      ],
    );
  }
}

class _CensusPrescriptionList extends StatelessWidget {
  const _CensusPrescriptionList({required this.items, required this.drawerStage});

  final List<PrescriptionItem> items;
  final MobileDrawerStage drawerStage;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPrescription);
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 6, right: 2),
      separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return RxOperationCard(
          item: item,
          isSelected: false,
          rfidStatus: null,
          isEligible: false,
          mode: RxOperationCardMode.census,
          onTap: () {},
        );
      },
    );
  }
}

class _CensusActionBar extends StatelessWidget {
  const _CensusActionBar({
    required this.drawerStage,
    required this.hasCountableItems,
    required this.baselineCompleted,
    required this.onStart,
  });

  final MobileDrawerStage drawerStage;
  final bool hasCountableItems;
  final bool baselineCompleted;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    // Çekmece açılıyor VEYA açıldı ama baseline henüz alınmadı → loading.
    final isOpening = drawerStage is MobileDrawerOpening || (drawerStage is MobileDrawerOpened && !baselineCompleted);

    return switch (drawerStage) {
      // Idle + sayılacak item var → başlat butonu
      MobileDrawerIdle() when hasCountableItems => SizedBox(
        width: context.width,
        child: MedButton(label: context.l10n.census_action_start, onPressed: onStart, isLoading: false),
      ),

      // Açılıyor / taranıyor → aynı buton ama loading, basılamaz
      MobileDrawerOpening() || MobileDrawerOpened() when isOpening => SizedBox(
        width: context.width,
        child: MedButton(label: context.l10n.census_action_start, onPressed: null, isLoading: true),
      ),

      _ => const SizedBox.shrink(),
    };
  }
}
