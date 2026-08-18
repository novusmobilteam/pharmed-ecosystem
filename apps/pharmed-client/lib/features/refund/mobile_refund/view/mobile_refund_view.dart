import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/cabin_shell_widgets/selection/patient_selection/view/patient_selection_guide.dart';
import '../../../../widgets/widgets.dart';
import '../../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../../dashboard/presentation/notifier/dashboard_state.dart';
import '../../refund.dart';

class MobileRefundView extends ConsumerWidget {
  const MobileRefundView({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinId = ref.watch(
      dashboardNotifierProvider.select(
        (s) => switch (s) {
          DashboardLoaded(:final data) => data.cabinVisualizerData?.cabinId,
          _ => null,
        },
      ),
    );

    if (cabinId == null) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return _MobileRefundBodyView(cabinId: cabinId, menu: menu);
  }
}

class _MobileRefundBodyView extends ConsumerStatefulWidget {
  const _MobileRefundBodyView({required this.cabinId, required this.menu});

  final int cabinId;
  final MenuItem menu;

  @override
  ConsumerState<_MobileRefundBodyView> createState() => _MobileRefundBodyViewState();
}

class _MobileRefundBodyViewState extends ConsumerState<_MobileRefundBodyView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.cabinId);
  }

  @override
  void didUpdateWidget(_MobileRefundBodyView old) {
    super.didUpdateWidget(old);
    _initialize(widget.cabinId);
  }

  void _initialize(int cabinId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(refundNotifierProvider.notifier).init(cabinId);
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
        MessageUtils.showSuccessDialog(
          context,
          context.l10n.refund_success_title,
          description: context.l10n.refund_success_message,
        );
        notifier.dismissSuccess();
      }
    });

    if (state is MobileRefundUninitialized || state is MobileRefundLoading) {
      return Center(child: MedLoadingIndicator());
    }

    if (state.hospitalizations.isEmpty) {
      return EmptyStateWidget(
        icon: PhosphorIcons.usersThree(),
        size: EmptyStateSize.normal,
        title: context.l10n.prescription_noPatients_title,
        description: context.l10n.prescription_noPatients_message,
      );
    }

    return CabinOperationSelectionLayout(
      left: PatientSelectionGuide(
        patients: state.hospitalizations,
        selectedPatient: state.selectedPatient,
        isPatientLoading: state.isPatientLoading,
        search: state.search,
        onPatientTap: notifier.onPatientTap,
        onSearchChanged: notifier.onSearchChanged,
      ),
      right: _RightPanel(state: state, notifier: notifier),
      footer: _RefundActionBar(
        state: state,
        onQuantityChanged: notifier.onQuantityChanged,
        onRefund: notifier.refund,
        onClear: notifier.clearSelection,
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({required this.state, required this.notifier});

  final MobileRefundState state;
  final RefundNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (state.isPrescriptionsLoading) {
      return Center(child: MedLoadingIndicator());
    }

    if (!state.isPatientSelected) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPatientSelected);
    }

    if (state.refundables.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noRefundableDrugs);
    }

    return RxDrugPanel(
      items: state.refundables,
      selectedItem: state.selectedItem,
      isBusy: state.isBusy,
      onDrugTap: notifier.onDrugTap,
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MedButton(
          label: context.l10n.common_dismissButton,
          variant: MedButtonVariant.ghost,
          size: MedButtonSize.sm,
          onPressed: selectedItem != null && !isBusy ? onClear : null,
        ),
        const SizedBox(width: MedSpacing.md),
        if (isBusy)
          MedButton(
            label: state.isChecking ? context.l10n.refund_action_checking : context.l10n.refund_action_refunding,
            variant: MedButtonVariant.primary,
            size: MedButtonSize.sm,
            isLoading: true,
            onPressed: null,
          )
        else
          MedButton(
            label: context.l10n.refund_action_refund,
            variant: MedButtonVariant.primary,
            size: MedButtonSize.sm,
            onPressed: canRefund ? onRefund : null,
          ),
      ],
    );
  }
}
