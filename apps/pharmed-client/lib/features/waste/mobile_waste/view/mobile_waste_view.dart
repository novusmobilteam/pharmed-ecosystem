import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../waste.dart';

import '../../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../../dashboard/presentation/notifier/dashboard_state.dart';

class MobileWasteView extends ConsumerWidget {
  const MobileWasteView({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinId = ref.watch(
      dashboardNotifierProvider.select(
        (s) => switch (s) {
          DashboardLoaded(:final data) => data.cabinVisualizerData?.cabinId,
          DashboardStale(:final data) => data.cabinVisualizerData?.cabinId,
          DashboardPartial(:final data) => data.cabinVisualizerData?.cabinId,
          _ => null,
        },
      ),
    );

    if (cabinId == null) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return _MobileWasteBodyView(cabinId: cabinId, menu: menu);
  }
}

class _MobileWasteBodyView extends ConsumerStatefulWidget {
  const _MobileWasteBodyView({required this.cabinId, required this.menu});

  final int cabinId;
  final MenuItem menu;

  @override
  ConsumerState<_MobileWasteBodyView> createState() => _MobileWasteBodyViewState();
}

class _MobileWasteBodyViewState extends ConsumerState<_MobileWasteBodyView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.cabinId);
  }

  @override
  void didUpdateWidget(_MobileWasteBodyView old) {
    super.didUpdateWidget(old);
    if (widget.cabinId != old.cabinId) _initialize(widget.cabinId);
  }

  void _initialize(int cabinId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(mobileWasteNotifierProvider.notifier).init(cabinId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileWasteNotifierProvider);
    final notifier = ref.read(mobileWasteNotifierProvider.notifier);

    // Hata / başarı snackbar
    ref.listen(mobileWasteNotifierProvider, (_, next) {
      if (next is MobileWasteError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      } else if (next is MobileWasteSuccess) {
        final msg = next.isWastage ? context.l10n.waste_success_wastage : context.l10n.waste_success_destruction;
        MessageUtils.showSuccessSnackbar(context, msg);
        notifier.dismissSuccess();
      }
    });

    if (state is MobileWasteUninitialized || state is MobileWasteLoading) {
      return Center(child: MedLoadingIndicator());
    }

    // Kabine atanmış hasta yoksa boş durum
    if (state.hospitalizations.isEmpty) {
      return EmptyStateWidget(
        card: false,
        icon: PhosphorIcons.usersThree(),
        size: EmptyStateSize.normal,
        title: context.l10n.prescription_noPatients_title,
        description: context.l10n.prescription_noPatients_message,
      );
    }

    return TwoColumnLayout(
      menuItem: widget.menu,
      leftTitle: context.l10n.common_patientListTitle,
      leftIcon: PhosphorIcons.users(),
      leftSubtitle: context.l10n.common_patientCountSubtitle(state.hospitalizations.length),
      left: PatientListPanel(
        patients: state.hospitalizations,
        selectedPatient: state.selectedPatient,
        isPatientLoading: state.isPatientLoading,
        search: state.search,
        onPatientTap: notifier.onPatientTap,
        onSearchChanged: notifier.onSearchChanged,
      ),
      right: _RightPanel(state: state, notifier: notifier),
      footer: _WasteActionBar(
        state: state,
        onQuantityChanged: notifier.onQuantityChanged,
        onWastage: notifier.wastage,
        onDestruction: notifier.destruction,
        onClear: notifier.clearSelection,
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({required this.state, required this.notifier});

  final MobileWasteState state;
  final MobileWasteNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (state.isPrescriptionsLoading) {
      return Center(child: MedLoadingIndicator());
    }

    if (!state.isPatientSelected) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPatientSelected);
    }

    if (state.disposables.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noWastableDrugs);
    }

    return RxDrugPanel(
      title: context.l10n.waste_panel_title,
      showFilters: false,
      items: state.disposables,
      selectedItem: state.selectedItem,
      isBusy: state.isSaving,
      onDrugTap: notifier.onDrugTap,
    );
  }
}

class _WasteActionBar extends StatelessWidget {
  const _WasteActionBar({
    required this.state,
    required this.onQuantityChanged,
    required this.onWastage,
    required this.onDestruction,
    required this.onClear,
  });

  final MobileWasteState state;
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback onWastage;
  final VoidCallback onDestruction;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final selectedItem = state.selectedItem;
    final isSaving = state.isSaving;
    final canWaste = state.canWaste;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MedButton(
          label: context.l10n.common_dismissButton,
          variant: MedButtonVariant.ghost,
          size: MedButtonSize.sm,
          onPressed: selectedItem != null && !isSaving ? onClear : null,
        ),
        const SizedBox(width: MedSpacing.md),
        if (isSaving)
          MedButton(
            label: context.l10n.common_action_processing,
            variant: MedButtonVariant.primary,
            size: MedButtonSize.sm,
            isLoading: true,
            onPressed: null,
          )
        else ...[
          MedButton(
            label: context.l10n.waste_action_wastage,
            variant: MedButtonVariant.secondary,
            size: MedButtonSize.sm,
            onPressed: canWaste ? onWastage : null,
          ),
          const SizedBox(width: MedSpacing.md),
          MedButton(
            label: context.l10n.waste_action_destruction,
            variant: MedButtonVariant.danger,
            size: MedButtonSize.sm,
            onPressed: canWaste ? onDestruction : null,
          ),
        ],
      ],
    );
  }
}
