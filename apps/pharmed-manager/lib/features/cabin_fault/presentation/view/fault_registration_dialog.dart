part of 'cabin_fault_view.dart';

class FaultRegistrationDialog extends StatelessWidget {
  const FaultRegistrationDialog({super.key, required this.faultRecords});

  final List<CabinFault> faultRecords;

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinFaultFormNotifier>(
      builder: (context, notifier, _) {
        final bool isUpdateMode = !notifier.isNewRecord;

        return RegistrationDialog(
          isLoading: notifier.isLoading(notifier.submitOp),
          title: isUpdateMode ? 'Kayıt Sonlandır' : 'Bakım/Arıza Bildirimi',
          saveButtonText: isUpdateMode ? 'Kayıt Sonlandır' : 'Kayıt Oluştur',
          onSave: () {
            notifier.submit(
              onFailed: (message) => MessageUtils.showErrorSnackbar(context, message),
              onSuccess: (message) {
                MessageUtils.showSuccessSnackbar(context, message);
                context.pop(true);
              },
            );
          },
          actions: [
            // Geçmiş Butonu
            if (faultRecords.isNotEmpty)
              RectangleIconButton(
                color: context.colorScheme.secondary,
                iconColor: context.colorScheme.onSecondary,
                iconData: PhosphorIcons.clockCounterClockwise(),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => FaultHistoryView(records: faultRecords),
                ),
              ),
          ],
          child: Column(
            spacing: AppDimensions.registrationDialogSpacing,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                child: PharmedSegmentedButton(
                  selectedIndex: notifier.selectedStatusIndex,
                  labels: const ['ARIZA', 'BAKIM'],
                  onChanged: notifier.setStatusIndex,
                ),
              ),
              TextInputField(
                key: ValueKey(notifier.activeFault.description),
                label: 'Açıklama',
                initialValue: notifier.activeFault.description,
                maxLines: 3,
                onChanged: (value) => notifier.updateDescription(value),
              ),
              if (isUpdateMode) ...[
                Spacer(),
                _buildActiveFaultInfo(context, notifier.activeFault),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveFaultInfo(BuildContext context, CabinFault fault) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bu çekmecede aktif bir ${fault.workingStatus?.label.toLowerCase()} bulunmaktadır. Onayladığınızda bu kayıt sonlandırılacaktır.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
