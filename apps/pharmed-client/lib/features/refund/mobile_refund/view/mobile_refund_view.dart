import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../widgets/widgets.dart';
import '../../refund.dart';

class MobileRefundView extends ConsumerStatefulWidget {
  const MobileRefundView({super.key});

  @override
  ConsumerState<MobileRefundView> createState() => _MobileRefundViewState();
}

class _MobileRefundViewState extends ConsumerState<MobileRefundView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(refundNotifierProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refundNotifierProvider);
    final notifier = ref.read(refundNotifierProvider.notifier);

    // Hata / başarı snackbar
    ref.listen(refundNotifierProvider, (_, next) {
      if (next is MobileRefundError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      } else if (next is MobileRefundSuccess) {
        MessageUtils.showSuccessSnackbar(context, next.message);
        notifier.dismissSuccess();
      }
    });

    if (state is MobileRefundUninitialized || state is MobileRefundLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Row(
      children: [
        SizedBox(
          width: 360,
          child: PatientListPanel(
            patients: state.patients,
            selectedPatient: state.selectedPatient,
            isPatientLoading: state.isPatientLoading,
            search: state.search,
            onPatientTap: notifier.onPatientTap,
            onSearchChanged: notifier.onSearchChanged,
          ),
        ),
        VerticalDivider(width: 1, thickness: 1, color: MedColors.border),
        Expanded(
          child: _RightPanel(state: state, notifier: notifier),
        ),
      ],
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({required this.state, required this.notifier});

  final MobileRefundState state;
  final RefundNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final selectedPatient = state.selectedPatient;

    if (selectedPatient == null) {
      return Center(child: EmptyStateWidget(variant: EmptyStateVariant.refundSelectPatient));
    }

    if (state.refundables.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noRefundableDrugs);
    }

    return Column(
      children: [
        Expanded(
          child: state.isPatientLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : RxDrugPanel(
                  title: 'İade Edilebilir İlaçlar',
                  items: state.refundables,
                  selectedItem: state.selectedItem,
                  isBusy: state.isBusy,
                  onDrugTap: notifier.onDrugTap,
                  hospitalization: selectedPatient,
                  showFilters: false,
                ),
        ),
        _RefundActionBar(
          state: state,
          onQuantityChanged: notifier.onQuantityChanged,
          onRefund: notifier.refund,
          onClear: notifier.clearSelection,
        ),
      ],
    );
  }
}

class _RefundActionBar extends StatelessWidget {
  const _RefundActionBar({
    required this.state,
    required this.onQuantityChanged,
    required this.onRefund,
    required this.onClear,
  });

  final MobileRefundState state;
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback onRefund;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final selectedItem = state.selectedItem;
    final isBusy = state.isBusy;
    final canRefund = state.canRefund;

    return Padding(
      padding: MedSpacing.insetLg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MedButton(
            label: 'Vazgeç',
            variant: MedButtonVariant.ghost,
            size: MedButtonSize.sm,
            onPressed: selectedItem != null && !isBusy ? onClear : null,
          ),
          const SizedBox(width: MedSpacing.md),
          if (isBusy)
            MedButton(
              label: state.isChecking ? 'Kontrol ediliyor...' : 'İade ediliyor...',
              variant: MedButtonVariant.primary,
              size: MedButtonSize.sm,
              isLoading: true,
              onPressed: null,
            )
          else
            MedButton(
              label: 'İade Et',
              variant: MedButtonVariant.primary,
              size: MedButtonSize.sm,
              onPressed: canRefund ? onRefund : null,
            ),
        ],
      ),
    );
  }
}
