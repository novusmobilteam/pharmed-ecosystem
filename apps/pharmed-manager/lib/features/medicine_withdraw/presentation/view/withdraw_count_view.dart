import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';

import '../notifier/withdraw_notifier.dart';

class WithdrawCountView extends StatelessWidget {
  const WithdrawCountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WithdrawNotifier>(
      builder: (context, notifier, _) {
        final plan = notifier.withdrawPlans[notifier.currentItem?.id] ?? [];
        final medicine = notifier.currentItem?.medicine;
        debugPrint('CountView currentItem: ${notifier.currentItem?.id}');
        debugPrint('CountView plan: ${notifier.withdrawPlans}');

        return RegistrationDialog(
          title: 'Stok Sayımı',
          width: context.width * 0.5,
          saveButtonText: 'Alımı Tamamla',
          isLoading: notifier.isLoading(notifier.completeOp),
          onClose: () async {
            await notifier.completeWithdraw(
              isCancelled: true,
              onFailed: (msg) {
                MessageUtils.showErrorSnackbar(context, msg);
              },
            );
            if (context.mounted) context.pop(false);
          },
          onSave: () async {
            bool? success;
            await notifier.completeWithdraw(
              onSuccess: (msg) {
                MessageUtils.showSuccessSnackbar(context, msg);
                success = true;
              },
              onFailed: (msg) {
                MessageUtils.showErrorSnackbar(context, msg);
                success = false;
              },
            );
            if (context.mounted) context.pop(success);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MedicineHeader(medicine: medicine),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: plan
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _SlotCountCard(
                              index: entry.key,
                              detail: entry.value,
                              doseUnit: medicine?.operationUnit ?? 'Adet',
                              showCensus: (medicine as Drug?)?.countType != CountType.noCount,
                              onCountTap: (index) async {
                                final result = await showNumpadView(context);
                                if (result != null) {
                                  notifier.updateCountAmount(index, result);
                                }
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MedicineHeader extends StatelessWidget {
  const _MedicineHeader({required this.medicine});

  final Medicine? medicine;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withAlpha(80),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.medication_rounded, color: colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medicine?.name ?? '-',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (medicine?.operationUnit != null)
                Text(
                  medicine?.operationUnit ?? 'Adet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SlotCountCard extends StatelessWidget {
  const _SlotCountCard({
    required this.index,
    required this.detail,
    required this.doseUnit,
    required this.onCountTap,
    required this.showCensus,
  });

  final int index;
  final WithdrawDetail detail;
  final String doseUnit;
  final Function(int index) onCountTap;
  final bool showCensus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: _SlotInfo(detail: detail, doseUnit: doseUnit),
          ),
          if (showCensus) // YENİ
            _CountButton(detail: detail, onTap: () => onCountTap(index)),
        ],
      ),
    );
  }
}

class _SlotInfo extends StatelessWidget {
  const _SlotInfo({required this.detail, required this.doseUnit});

  final WithdrawDetail detail;
  final String doseUnit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alınan Miktar',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          '${detail.dosePiece.formatFractional} $doseUnit',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _CountButton extends StatelessWidget {
  const _CountButton({required this.detail, required this.onTap});

  final WithdrawDetail detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasCensus = detail.censusQuantity != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: hasCensus ? colorScheme.primaryContainer.withAlpha(80) : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasCensus ? colorScheme.primary.withAlpha(120) : colorScheme.outlineVariant.withAlpha(60),
          ),
        ),
        child: Column(
          children: [
            Text(
              'Sayım',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: hasCensus ? colorScheme.primary : colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 2),
            Text(
              detail.censusQuantity?.formatFractional ?? '—',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: hasCensus ? colorScheme.primary : colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
