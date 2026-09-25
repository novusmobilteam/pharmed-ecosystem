import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../notifier/master_intake_selection_notifier.dart';

class IntakeCheckDialog extends ConsumerStatefulWidget {
  const IntakeCheckDialog({super.key, required this.onQueueReady});

  final void Function(List<CabinOperationDrawerJob> jobs, List<IntakePlan> plans) onQueueReady;

  @override
  ConsumerState<IntakeCheckDialog> createState() => _IntakeCheckDialogState();
}

class _IntakeCheckDialogState extends ConsumerState<IntakeCheckDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final notifier = ref.read(masterIntakeSelectionNotifierProvider);
    await notifier.startIntake(
      onQueueReady: (jobs, plans) {
        if (!mounted) return;
        Navigator.of(context).pop();
        widget.onQueueReady(jobs, plans);
      },
      onFailed: (_) {}, // dialog açık kalır, aşağıdaki liste zaten kırmızı satırı gösteriyor
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(masterIntakeSelectionNotifierProvider);
    final items = notifier.selectedItems;
    final hasError = notifier.isFailed(notifier.startIntakeOp);
    final completed = items
        .where(
          (it) =>
              notifier.isSuccess(notifier.checkItemOpFor(it.id)) || notifier.isFailed(notifier.checkItemOpFor(it.id)),
        )
        .length;

    return PopScope(
      canPop: hasError,
      child: Dialog(
        child: Container(
          width: 620,
          padding: MedSpacing.insetXl * 2,
          decoration: MedDecoration.panelDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.intake_status_checking, style: MedTextStyles.titleSm()),
                  Text('$completed / ${items.length}', style: MedTextStyles.bodySm(color: MedColors.text3)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: MedRadius.smAll,
                child: LinearProgressIndicator(
                  value: items.isEmpty ? 0 : completed / items.length,
                  minHeight: 4,
                  backgroundColor: MedColors.surface2,
                  color: hasError ? MedColors.red : MedColors.blue,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final op = notifier.checkItemOpFor(item.id);
                    return _CheckRow(
                      label: item.medicine?.name ?? '',
                      isLoading: notifier.isLoading(op),
                      isSuccess: notifier.isSuccess(op),
                      isFailed: notifier.isFailed(op),
                      errorMessage: notifier.message(op),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Divider(),
              Row(
                spacing: 12.0,
                mainAxisAlignment: MainAxisAlignment.end,

                children: [
                  MedButton(
                    label: context.l10n.common_cancelButton,
                    variant: MedButtonVariant.error,

                    size: MedButtonSize.sm,
                    onPressed: hasError ? () => Navigator.of(context).pop() : null,
                  ),
                  MedButton(
                    label: context.l10n.intake_action_continue,
                    variant: MedButtonVariant.primary,
                    size: MedButtonSize.sm,
                    suffixIcon: Icon(PhosphorIcons.arrowRight()),
                    onPressed: (hasError && notifier.hasSuccessfulItemsToStart)
                        ? () {
                            final jobs = notifier.pendingJobs;
                            final plans = notifier.pendingPlans;
                            Navigator.of(context).pop();
                            widget.onQueueReady(jobs, plans);
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.isLoading,
    required this.isSuccess,
    required this.isFailed,
    this.errorMessage,
  });

  final String label;
  final bool isLoading;
  final bool isSuccess;
  final bool isFailed;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(color: isFailed ? MedColors.redLight : null, borderRadius: MedRadius.mdAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(width: 18, height: 18, child: MedLoadingIndicator())
              else if (isSuccess)
                Icon(PhosphorIconsBold.check, size: 18, color: MedColors.green)
              else if (isFailed)
                Icon(PhosphorIconsBold.x, size: 18, color: MedColors.red)
              else
                Icon(PhosphorIconsBold.minus, size: 18, color: MedColors.text3),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label, style: MedTextStyles.titleSm(color: isFailed ? MedColors.red : null)),
              ),
            ],
          ),
          if (isFailed && errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 2),
              child: Text(errorMessage!, style: MedTextStyles.bodyMd(color: MedColors.red)),
            ),
        ],
      ),
    );
  }
}
