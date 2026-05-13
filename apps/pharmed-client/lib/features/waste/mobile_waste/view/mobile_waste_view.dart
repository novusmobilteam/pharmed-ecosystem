import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../waste.dart';

class MobileWasteView extends ConsumerStatefulWidget {
  const MobileWasteView({super.key});

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
        MessageUtils.showSuccessSnackbar(context, next.message);
        notifier.dismissSuccess();
      }
    });

    if (state is MobileWasteUninitialized || state is MobileWasteLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Row(
      children: [
        SizedBox(
          width: 360,
          child: WastePatientList(
            patients: state.filteredPatients,
            selectedPatient: state.selectedPatient,
            isPatientLoading: state.isPatientLoading,
            search: state.search,
            onPatientTap: notifier.onPatientTap,
            onSearchChanged: notifier.onSearchChanged,
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: _RightPanel(state: state, notifier: notifier),
        ),
      ],
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

    return Column(
      children: [
        Expanded(
          child: WasteDrugList(
            items: state.disposables,
            selectedItem: state.selectedItem,
            isBusy: state.isSaving,
            onDrugTap: notifier.onDrugTap,
          ),
        ),
        _WasteActionBar(
          state: state,
          onQuantityChanged: notifier.onQuantityChanged,
          onWastage: notifier.wastage,
          onDestruction: notifier.destruction,
          onClear: notifier.clearSelection,
        ),
      ],
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

    return Padding(
      padding: MedSpacing.insetLg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MedButton(
            label: 'Vazgeç',
            variant: MedButtonVariant.ghost,
            size: MedButtonSize.md,
            onPressed: selectedItem != null && !isSaving ? onClear : null,
          ),
          const SizedBox(width: MedSpacing.md),
          if (isSaving)
            MedButton(
              label: 'İşlem yapılıyor...',
              variant: MedButtonVariant.primary,
              size: MedButtonSize.md,
              isLoading: true,
              onPressed: null,
            )
          else ...[
            MedButton(
              label: 'Fire Et',
              variant: MedButtonVariant.secondary,
              size: MedButtonSize.md,
              onPressed: canWaste ? onWastage : null,
            ),
            const SizedBox(width: MedSpacing.md),
            MedButton(
              label: 'İmha Et',
              variant: MedButtonVariant.danger,
              size: MedButtonSize.md,
              onPressed: canWaste ? onDestruction : null,
            ),
          ],
        ],
      ),
    );
  }
}
