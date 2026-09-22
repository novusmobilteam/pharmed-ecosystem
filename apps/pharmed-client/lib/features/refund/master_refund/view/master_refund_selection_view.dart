part of 'master_refund_view.dart';

class MasterRefundSelectionView extends StatelessWidget {
  const MasterRefundSelectionView({super.key, required this.notifier, required this.menu, required this.onStartRefund});

  final MenuItem menu;
  final MasterRefundSelectionNotifier notifier;
  final VoidCallback onStartRefund;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenTitle(menu: menu),
        Expanded(
          child: Row(
            spacing: 12.0,
            children: [
              Expanded(flex: 2, child: _LeftPanel(notifier: notifier)),
              Expanded(flex: 7, child: _RightPanel(notifier, onStartRefund)),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeftPanel extends StatelessWidget {
  const _LeftPanel({required this.notifier});

  final MasterRefundSelectionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    // final myIds = notifier.myPatientHospitalizationIds;
    return HospitalizationPanel(
      cellBuilder: (hosp) {
        final hospId = hosp.id;
        bool isSelected = notifier.selectedHospitalization?.id == hospId;
        return PatientSelectionCard(
          hospitalization: hosp,
          onTap: () => notifier.selectHospitalization(hosp),
          showChevron: false,
          isSelected: isSelected,
        );
      },
      onTypeChanged: () => notifier.clearSelection(),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel(this.notifier, this.onStartRefund);

  final MasterRefundSelectionNotifier notifier;
  final VoidCallback onStartRefund;

  @override
  Widget build(BuildContext context) {
    final title = notifier.selectedHospitalization != null
        ? notifier.selectedHospitalization?.patient?.fullName ?? '-'
        : 'Hasta Seçilmedi';
    return Container(
      alignment: Alignment.center,
      decoration: MedDecoration.panelDecoration,
      child: Builder(
        builder: (context) {
          if (notifier.isLoading(notifier.fetchRefundablesOp)) return Center(child: MedLoadingIndicator());
          if (notifier.selectedHospitalization == null) return Center(child: NoSelectedHospitalizationView());
          if (notifier.selectedHospitalization != null && notifier.refundables.isEmpty) {
            return Center(
              child: NoDataView(
                title: context.l10n.refund_noRefundableDrugs,
                subtitle: context.l10n.refund_selectPatient,
                iconData: PhosphorIcons.arrowUUpLeft(),
              ),
            );
          }

          return Column(
            spacing: 4.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: MedSpacing.insetXl,
                child: Text(title, style: MedTextStyles.titleSm()),
              ),
              Divider(height: 0),

              Expanded(child: _RefundablesListView(notifier)),
              // Footer
              if (notifier.refundables.isNotEmpty)
                Container(
                  alignment: Alignment.centerRight,
                  height: 60,
                  decoration: BoxDecoration(color: MedColors.surface2),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: MedButton(
                      label: notifier.isStartingRefund ? 'Başlatılıyor...' : 'İadeyi Başlat',
                      size: MedButtonSize.sm,
                      suffixIcon: Icon(PhosphorIcons.arrowRight()),
                      isLoading: notifier.isStartingRefund,
                      onPressed: notifier.selectedItems.isEmpty || notifier.isStartingRefund
                          ? null
                          : () => onStartRefund(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RefundablesListView extends StatelessWidget {
  const _RefundablesListView(this.notifier);

  final MasterRefundSelectionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: notifier.refundables.length,
      separatorBuilder: (BuildContext context, int index) {
        return Divider(height: 1, color: MedColors.border);
      },
      itemBuilder: (BuildContext context, int index) {
        final item = notifier.refundables.elementAt(index);
        final bool isSelected = notifier.selectedItems.contains(item);
        final foreground = isSelected ? Colors.white : MedColors.text;
        final refundType = item.medicine?.returnType;
        final bool showCheckbox =
            (refundType?.requiresCabinHardware ?? false) && (item.medicine?.canRefundable ?? false);

        final currentAmount = notifier.amountFor(item.id);
        final maxAmount = notifier.maxAmountFor(item.id);
        final directStatus = notifier.itemStatuses[item.id];
        final isDirectLoading = directStatus is RefundCheckLoading;

        final bool isRefundable = (item.medicine?.canRefundable ?? false) && item.isCollectedAtCurrentStation;
        final displayReturnType = isRefundable ? refundType : ReturnType.nonRefundable;

        return GestureDetector(
          onTap: () => notifier.selectRefundableItem(item),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              spacing: 12.0,
              children: [
                if (isRefundable && showCheckbox)
                  MedCheckbox(value: isSelected, onChanged: (_) {}, size: MedCheckboxSize.md)
                else if (isRefundable && !showCheckbox)
                  MedRectangleIconButton(
                    iconData: PhosphorIcons.lightning(),
                    size: 22,
                    color: MedColors.greenLight,
                    iconColor: MedColors.green,
                  ),

                // Doz
                Container(
                  height: 45,
                  width: 45,
                  //padding: MedSpacing.insetLg,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? MedColors.blue : MedColors.surface2,
                    borderRadius: MedRadius.lgAll,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.dosePiece.formatFractional.toString(), style: MedTextStyles.titleMd(color: foreground)),
                      Text(
                        item.medicine?.operationUnitLocalized(context) ?? '',
                        style: MedTextStyles.bodySm(color: foreground),
                      ),
                    ],
                  ),
                ),
                // İlaç Bilgileri
                Column(
                  spacing: 4.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.medicineName, style: MedTextStyles.titleSm()),
                    Row(
                      spacing: 6.0,
                      children: [
                        Text(item.medicineBarcode, style: MedTextStyles.monoSm()),
                        Text('-', style: MedTextStyles.monoSm()),
                        Text(
                          context.l10n.refund_appliedDateLabel(item.time.formattedDateTime),
                          style: MedTextStyles.monoSm(),
                        ),

                        Text('-', style: MedTextStyles.monoSm()),
                        Text(
                          context.l10n.refund_performedByLabel(item.lastMovement?.performedBy?.fullName ?? ''),
                          style: MedTextStyles.monoSm(),
                        ),
                      ],
                    ),

                    Row(
                      spacing: 6.0,
                      children: [
                        MedChip(
                          label: displayReturnType?.label ?? '-',
                          background: displayReturnType?.bakcgroundColor,
                          foreground: displayReturnType?.foregroundColor,
                          showBorder: false,
                          shape: MedChipShape.pill,
                        ),
                        if (item.collectStationName != null)
                          MedChip(
                            label: item.collectStationName!,
                            background: MedColors.purple,
                            foreground: Colors.white,
                            showBorder: false,
                            shape: MedChipShape.pill,
                          ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                if (isRefundable)
                  SizedBox(
                    width: 130,
                    child: MedDoseStepper(
                      type: DoseStepperType.compact,
                      value: currentAmount.toDouble(),
                      min: 0.01,
                      max: maxAmount.toDouble(),
                      onChanged: (v) => notifier.updateAmount(
                        item.id,
                        v,
                        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                      ),
                      unit: item.medicine?.operationUnitLocalized(context) ?? '',
                    ),
                  ),

                if (!showCheckbox && isRefundable)
                  MedButton(
                    label: isDirectLoading
                        ? context.l10n.refund_directReturnSendingLabel
                        : context.l10n.refund_directReturnButton,
                    size: MedButtonSize.sm,
                    variant: MedButtonVariant.success,
                    prefixIcon: Icon(PhosphorIcons.arrowUUpLeft()),
                    isLoading: isDirectLoading,
                    onPressed: isDirectLoading
                        ? null
                        : () async {
                            notifier.completeDirectRefund(
                              item.id,
                              onSuccess: () => MessageUtils.showSuccessSnackbar(
                                context,
                                context.l10n.common_operationSuccessMessage,
                              ),
                              onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                            );
                          },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
