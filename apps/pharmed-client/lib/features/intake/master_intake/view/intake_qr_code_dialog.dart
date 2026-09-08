part of 'master_intake_view.dart';

class IntakeQrCodeDialog extends ConsumerStatefulWidget {
  const IntakeQrCodeDialog({super.key});

  @override
  ConsumerState<IntakeQrCodeDialog> createState() => _IntakeQrCodeDialogState();
}

class _IntakeQrCodeDialogState extends ConsumerState<IntakeQrCodeDialog> {
  final Map<int, List<TextEditingController>> _fieldsByRequirement = {};

  List<TextEditingController> _fieldsFor(IntakeQrCodeRequirement req) => _fieldsByRequirement.putIfAbsent(
    req.prescriptionDetailId,
    () => List.generate(req.requiredCount, (_) => TextEditingController()),
  );

  @override
  void dispose() {
    for (final list in _fieldsByRequirement.values) {
      for (final c in list) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Map<int, List<String>> _collect() {
    final result = <int, List<String>>{};
    for (final entry in _fieldsByRequirement.entries) {
      final codes = entry.value.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
      if (codes.isNotEmpty) result[entry.key] = codes;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterIntakeNotifierProvider);
    final notifier = ref.read(masterIntakeNotifierProvider.notifier);

    final executing = switch (state) {
      MasterIntakeExecuting e => e,
      MasterIntakeError(previousState: MasterIntakeExecuting e) => e,
      _ => null,
    };

    if (executing?.qrCodeJob == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }

    final requirements = executing!.qrCodeRequirements;
    final errors = executing.qrCodeErrors;
    final isSubmitting = executing.isSubmittingQrCodes;
    final hasErrors = errors.isNotEmpty;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: MedSpacing.insetXl * 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.intake_qrCode_dialogTitle, style: MedTextStyles.titleMd()),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final req in requirements) ...[
                        Text(req.medicineName, style: MedTextStyles.titleSm()),
                        const SizedBox(height: 8),
                        for (var i = 0; i < req.requiredCount; i++) ...[
                          TextField(
                            controller: _fieldsFor(req)[i],
                            enabled: !isSubmitting && !hasErrors,
                            decoration: InputDecoration(hintText: context.l10n.intake_qrCode_fieldHint(i + 1)),
                          ),
                          const SizedBox(height: 6),
                        ],
                        if (errors[req.prescriptionDetailId] != null)
                          Text(errors[req.prescriptionDetailId]!, style: MedTextStyles.bodySm(color: MedColors.red)),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (hasErrors)
                MedButton(label: context.l10n.common_okButton, onPressed: notifier.acknowledgeQrCodeErrorsAndContinue)
              else
                MedButton(
                  label: context.l10n.intake_action_complete,
                  isLoading: isSubmitting,
                  onPressed: isSubmitting ? null : () => notifier.submitQrCodesAndContinue(_collect()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
