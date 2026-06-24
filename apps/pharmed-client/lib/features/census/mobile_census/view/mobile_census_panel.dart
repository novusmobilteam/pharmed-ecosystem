import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/enums/cabin_operation_mode.dart';
import '../../../../core/providers/providers.dart';
import '../../census.dart';

part 'report_extra_stock_dialog.dart';
part 'extra_stock_summary_card.dart';
part 'rx_census_group_card.dart';

class MobileCensusPanel extends StatelessWidget {
  const MobileCensusPanel({
    super.key,
    required this.notifier,
    required this.state,
    required this.drawerStage,
    required this.onStartCensus,
    required this.onCompleteCensus,
    required this.onReopenDrawer,
    required this.onSelectAssignment,
    required this.onChangePatient,
    required this.onToggleItem,
    required this.onCancelCensus,
  });

  final MobileCensusNotifier notifier;
  final MobileCensusState state;
  final MobileDrawerStage drawerStage;
  final VoidCallback onStartCensus;
  final VoidCallback onCompleteCensus;
  final VoidCallback onReopenDrawer;
  final ValueChanged<BedAssignment> onSelectAssignment;
  final VoidCallback onChangePatient;
  final ValueChanged<int> onToggleItem;
  final VoidCallback onCancelCensus;

  /// Süreç aktif (Opening/Opened/Closed) mı?
  bool get _isProcessActive => drawerStage.isActive;

  /// Çekmece açılıyor veya açıkken seçim değiştirilemez.
  bool get _isSelectionLocked => drawerStage is! MobileDrawerOpened;

  @override
  Widget build(BuildContext context) {
    return OperationPanelBase(
      mode: CabinOperationMode.census,
      child: switch (state) {
        MobileCensusUninitialized() ||
        MobileCensusLoading() => const Center(child: CircularProgressIndicator(strokeWidth: 2)),

        // Hasta seçilmediği tüm durumlarda → liste göster
        MobileCensusIdle() || MobileCensusSlotSelected() || MobileCensusNoPatient() => CabinPatientPickerList(
          assignments: state.availableAssignments,
          onSelected: onSelectAssignment,
        ),

        MobileCensusReady ready => _buildReady(context, notifier, ready),

        // Kaydetme ve başarı sırasında Ready görünümü korunur
        MobileCensusSaving(:final ready) || MobileCensusSuccess(:final ready) => _buildReady(context, notifier, ready),

        MobileCensusError(:final previousState) => switch (previousState) {
          MobileCensusReady ready => _buildReady(context, notifier, ready),
          MobileCensusSaving(:final ready) => _buildReady(context, notifier, ready),
          _ => CabinPatientPickerList(assignments: previousState.availableAssignments, onSelected: onSelectAssignment),
        },
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
        // Sayım aktifken filtreler yerine fazla stok butonu
        if (_isProcessActive) ...[
          _ReportExtraStockButton(onReport: notifier.addExtraStock),
          _ExtraStockSummaryCard(extraStocks: ready.extraStocks, onRemove: notifier.removeExtraStock),
        ] else ...[
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
        Expanded(
          child: _CensusPrescriptionList(
            items: ready.prescriptionItems,
            selectedItemIds: ready.selectedItemIds,
            isSelectionLocked: _isSelectionLocked,
            rfidReadEpcs: ready.rfidReadEpcs,
            isProcessActive: _isProcessActive,
            onToggleItem: onToggleItem,
            drawerStage: drawerStage,
            ready: ready,
          ),
        ),
        _CensusActionBar(
          drawerStage: drawerStage,
          hasSelection: ready.selectedItemIds.isNotEmpty,
          canComplete: ready.canComplete,
          rfidPresentCount: ready.rfidPresentCount,
          isSaving: state is MobileCensusSaving,
          onStart: onStartCensus,
          onComplete: onCompleteCensus,
          onReopen: onReopenDrawer,
          onCancel: onCancelCensus,
        ),
      ],
    );
  }
}

class _CensusPrescriptionList extends StatelessWidget {
  const _CensusPrescriptionList({
    required this.items,
    required this.selectedItemIds,
    required this.rfidReadEpcs,
    required this.isSelectionLocked,
    required this.isProcessActive,
    required this.onToggleItem,
    required this.drawerStage,
    required this.ready,
  });

  final List<PrescriptionItem> items;
  final Set<int> selectedItemIds;

  /// Şu an okuyucu tarafından görülen EPC'ler — kabinde fiziksel olarak mevcut.
  final Set<String> rfidReadEpcs;

  /// Çekmece açılıyor veya açıkken true — seçim kilitli.
  final bool isSelectionLocked;

  /// RFID session aktif mi (çekmece herhangi bir aktif aşamada mı)?
  final bool isProcessActive;

  final ValueChanged<int> onToggleItem;
  final MobileDrawerStage drawerStage;
  final MobileCensusReady ready;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPrescription);
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 6, right: 2),
      separatorBuilder: (_, __) => const SizedBox(height: MedSpacing.sm),
      itemCount: ready.groups.length,
      itemBuilder: (context, index) {
        final group = ready.groups[index];
        return RxCensusGroupCard(
          group: group,
          isProcessActive: isProcessActive,
          isSelectionLocked: isSelectionLocked,
          onToggleItem: onToggleItem,
        );
      },
    );
  }
}

class _CensusActionBar extends StatelessWidget {
  const _CensusActionBar({
    required this.drawerStage,
    required this.hasSelection,
    required this.canComplete,
    required this.rfidPresentCount,
    required this.isSaving,
    required this.onStart,
    required this.onComplete,
    required this.onReopen,
    required this.onCancel,
  });

  final MobileDrawerStage drawerStage;
  final bool hasSelection;

  /// Seçili RFID'li tüm item'ların EPC'si şu an okunuyor mu?
  /// [MobileCensusReady.canComplete] getter'ından gelir.
  final bool canComplete;

  /// Şu an okunan (kabinde mevcut) seçili RFID'li ilaç sayısı.
  /// [MobileCensusReady.rfidPresentCount] getter'ından gelir.
  final int rfidPresentCount;

  final bool isSaving;

  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onReopen;
  final VoidCallback onCancel;

  bool get _showCancel {
    if (isSaving) return false;
    if (drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened) return false;
    if (drawerStage is MobileDrawerIdle) return hasSelection;
    if (drawerStage is MobileDrawerClosed) return rfidPresentCount == 0;
    if (drawerStage is MobileDrawerFailed) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (_showCancel) _CancelButton(onTap: onCancel) else const Spacer(),
        const Spacer(),
        _buildAction(context),
      ],
    );
  }

  Widget _buildAction(BuildContext context) {
    if (isSaving) {
      return _ActionButton(label: context.l10n.common_action_saving, enabled: false, loading: true, onTap: _noop);
    }

    return switch (drawerStage) {
      MobileDrawerOpening() => _ActionButton(
        label: context.l10n.common_action_drawerOpening,
        enabled: false,
        loading: true,
        onTap: _noop,
      ),
      MobileDrawerOpened() => _ActionButton(label: context.l10n.census_action_drawerOpen, enabled: false, onTap: _noop),
      MobileDrawerClosed() =>
        canComplete
            ? _ActionButton(label: context.l10n.census_action_complete, onTap: onComplete)
            : _ActionButton(label: context.l10n.census_action_continue, onTap: onReopen),
      MobileDrawerFailed() => _ActionButton(label: context.l10n.common_retryButton, onTap: onStart),
      MobileDrawerIdle() => _ActionButton(label: context.l10n.census_action_start, onTap: onStart),
    };
  }
}

// ignore: avoid_returning_null_for_void
void _noop() {}

// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap, this.enabled = true, this.loading = false});

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return MedButton(
      label: label,
      size: MedButtonSize.sm,
      isLoading: loading,
      onPressed: enabled && !loading ? onTap : null,
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MedButton(
      label: context.l10n.common_cancelButton,
      size: MedButtonSize.sm,
      variant: MedButtonVariant.danger,
      onPressed: onTap,
    );
  }
}

class _ReportExtraStockButton extends StatelessWidget {
  const _ReportExtraStockButton({required this.onReport});

  final void Function({required Medicine medicine, required double quantity}) onReport;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MedButton(
        label: context.l10n.census_action_report_extra_stock,
        size: MedButtonSize.md,
        variant: MedButtonVariant.secondary,

        onPressed: () async {
          final result = await ReportExtraStockDialog.show(context);
          if (result != null) {
            onReport(medicine: result.medicine, quantity: result.quantity);
          }
        },
      ),
    );
  }
}
