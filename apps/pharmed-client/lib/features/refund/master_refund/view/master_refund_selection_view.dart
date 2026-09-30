part of 'master_refund_view.dart';

class MasterRefundSelectionView extends StatelessWidget {
  const MasterRefundSelectionView({
    super.key,
    required this.stationContext,
    required this.notifier,
    required this.onStartRefund,
  });

  final StationCabinsContext stationContext;
  final MasterRefundSelectionNotifier notifier;
  final VoidCallback onStartRefund;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: MedSpacing.xl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenTitle(menu: stationContext.menu),
        Expanded(
          child: Row(
            spacing: MedSpacing.lg,
            children: [
              Expanded(flex: 2, child: _RefundPatientPanel(notifier: notifier)),
              Expanded(
                flex: 7,
                child: _RefundRightPanel(notifier: notifier, onStartRefund: onStartRefund),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sol panel. Şimdilik mevcut HospitalizationPanel ile devam ediyor —
/// alımdaki PatientSelectionView'a geçiş ayrı bir adım.
class _RefundPatientPanel extends StatelessWidget {
  const _RefundPatientPanel({required this.notifier});

  final MasterRefundSelectionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: notifier.isStartingRefund,
      child: HospitalizationPanel(
        cellBuilder: (hosp) => PatientSelectionCard(
          hospitalization: hosp,
          onTap: () => notifier.selectHospitalization(hosp),
          showChevron: false,
          isSelected: notifier.selectedHospitalization?.id == hosp.id,
        ),
        onTypeChanged: notifier.clearSelection,
      ),
    );
  }
}

class _RefundRightPanel extends StatelessWidget {
  const _RefundRightPanel({required this.notifier, required this.onStartRefund});

  final MasterRefundSelectionNotifier notifier;
  final VoidCallback onStartRefund;

  @override
  Widget build(BuildContext context) {
    final hosp = notifier.selectedHospitalization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hosp != null) HospitalizationInfoCard(key: ValueKey(hosp.id), hospitalization: hosp),

        Expanded(
          child: Container(
            padding: MedSpacing.insetLg,
            decoration: MedDecoration.panelDecoration,
            child: _RefundablesContent(notifier: notifier),
          ),
        ),

        // Footer yalnızca seçim varken görünür; başlatma sürerken de görünür
        // kalır (buton loading gösterir), alımdaki gibi kaybolmaz.
        if (notifier.hasSelection) ...[
          const SizedBox(height: MedSpacing.sm),
          Container(
            padding: MedSpacing.insetLg,
            alignment: Alignment.centerRight,
            decoration: MedDecoration.panelDecoration,
            child: MedButton(
              label: notifier.isStartingRefund ? context.l10n.refund_action_start : context.l10n.refund_action_start,
              suffixIcon: Icon(PhosphorIcons.arrowRight()),
              isLoading: notifier.isStartingRefund,
              onPressed: notifier.canStart ? onStartRefund : null,
            ),
          ),
        ],
      ],
    );
  }
}

class _RefundablesContent extends StatelessWidget {
  const _RefundablesContent({required this.notifier});

  final MasterRefundSelectionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (notifier.selectedHospitalization == null) {
      return EmptySelectionView(
        title: context.l10n.common_noPatientSelectedEmptyTitle,
        description: context.l10n.refund_selectionEmptyDescription,
      );
    }

    if (notifier.isFetchingRefundables) {
      return Center(child: MedLoadingIndicator());
    }

    // Hata artık tüm ekranı değil yalnızca bu paneli kaplar — hasta listesi
    // erişilebilir kalır, kullanıcı tekrar deneyebilir ya da başka hasta seçebilir.
    if (notifier.isFetchFailed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: MedSpacing.lg,
          children: [
            EmptyStateWidget(variant: EmptyStateVariant.networkError),
            MedButton(
              label: context.l10n.common_retryButton,
              size: MedButtonSize.sm,
              prefixIcon: Icon(PhosphorIcons.arrowClockwise()),
              onPressed: notifier.retryFetch,
            ),
          ],
        ),
      );
    }

    if (notifier.refundables.isEmpty) {
      return NoDataView(
        title: context.l10n.refund_noRefundableDrugs,
        subtitle: context.l10n.refund_selectPatient,
        iconData: PhosphorIcons.arrowUUpLeft(),
      );
    }

    return ListView.separated(
      itemCount: notifier.refundables.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: MedColors.border),
      itemBuilder: (_, index) {
        final item = notifier.refundables[index];
        return RefundableItemCard(key: ValueKey(item.id), notifier: notifier, item: item);
      },
    );
  }
}
