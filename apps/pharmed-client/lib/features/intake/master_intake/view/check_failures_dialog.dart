part of 'master_intake_view.dart';

class CheckFailuresDialog extends StatelessWidget {
  const CheckFailuresDialog({super.key, required this.failures, required this.onCancel, required this.onProceed});

  final List<({IntakeItem item, String? message})> failures;
  final VoidCallback onCancel;
  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    return MedDialog(
      title: 'context.l10n.intake_checkFailuresDialogTitle',
      icon: PhosphorIcons.warningCircle(),
      width: 480,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: failures.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final f = failures[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.item.medicine?.name ?? '—', style: MedTextStyles.bodyMd(weight: FontWeight.bold)),
                      Text(
                        f.message ?? context.l10n.intake_status_checkFailed,
                        style: MedTextStyles.bodySm(color: MedColors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: MedButton(
                  label: context.l10n.common_cancelButton,
                  variant: MedButtonVariant.secondary,
                  onPressed: onCancel,
                ),
              ),
              Expanded(
                child: MedButton(
                  label: 'context.l10n.intake_checkFailuresDialogProceedButton',
                  variant: MedButtonVariant.danger,
                  onPressed: onProceed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
