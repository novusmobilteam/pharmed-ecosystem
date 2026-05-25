import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../waste.dart';

class MobileWasteView extends ConsumerStatefulWidget {
  const MobileWasteView({super.key, required this.menu});

  final MenuItem menu;

  @override
  ConsumerState<MobileWasteView> createState() => _MobileWasteViewState();
}

class _MobileWasteViewState extends ConsumerState<MobileWasteView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(mobileWasteNotifierProvider.notifier).init();
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
        final msg = next.isWastage
            ? context.l10n.waste_success_wastage
            : context.l10n.waste_success_destruction;
        MessageUtils.showSuccessSnackbar(context, msg);
        notifier.dismissSuccess();
      }
    });

    if (state is MobileWasteUninitialized || state is MobileWasteLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return TwoColumnLayout(
      menuItem: widget.menu,
      leftTitle: context.l10n.common_patientListTitle,
      leftIcon: PhosphorIcons.users(),
      leftSubtitle: context.l10n.common_patientCountSubtitle(state.patients.length),
      left: PatientListPanel(
        patients: state.patients,
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
    final selectedPatient = state.selectedPatient;

    if (selectedPatient == null) {
      return const Center(child: EmptyStateWidget(variant: EmptyStateVariant.wasteSelectPatient));
    }

    if (state.isPatientLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
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
