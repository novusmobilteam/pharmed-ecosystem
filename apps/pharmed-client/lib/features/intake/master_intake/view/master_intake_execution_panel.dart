// [SWREQ-CLI-MINTAKE-006] [IEC 62304 §5.5]
// FAZ 2 — Alım kuyruğunun işlendiği panel.
//
// Master dolumdaki MasterRefillExecutionPanel'in alım karşılığıdır. Form içeriği
// "dolum" değil "sayım"dır:
//   - Kübik: yalnızca o an açık olan TEK gözün sayım formu (lid-by-lid).
//   - Birim doz/standart: çekmecenin tüm hedefleri tek formda.
//
// CountType davranışı:
//   - noCount: sayım girişi gösterilmez, yalnızca alınan miktar; doğrudan onay.
//   - normalCount: mevcut stok dolu gelir, kullanıcı düzeltir.
//   - blindCount: boş gelir, kullanıcı girer.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../intake.dart';

class MasterIntakeExecutionPanel extends ConsumerWidget {
  const MasterIntakeExecutionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterIntakeNotifierProvider);

    final executing = switch (state) {
      MasterIntakeExecuting e => e,
      MasterIntakeError(previousState: MasterIntakeExecuting e) => e,
      _ => null,
    };

    if (executing == null) {
      return EmptyStateWidget(title: context.l10n.intake_emptyState_selectMedicine);
    }

    final notifier = ref.read(masterIntakeNotifierProvider.notifier);
    final drawerStage = ref.watch(masterDrawerSessionProvider).stage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProgressBar(state: executing),
        const SizedBox(height: 12),
        Expanded(
          child: _ActiveForm(state: executing, drawerStage: drawerStage, notifier: notifier),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.state});

  final MasterIntakeExecuting state;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 6,
              backgroundColor: MedColors.border2,
              valueColor: const AlwaysStoppedAnimation(MedColors.blue),
            ),
          ),
        ),
        Text(
          context.l10n.refill_label_queueProgress(state.completedJobs, state.totalJobs),
          style: MedTextStyles.monoSm(color: MedColors.text3),
        ),
      ],
    );
  }
}

class _ActiveForm extends StatelessWidget {
  const _ActiveForm({required this.state, required this.drawerStage, required this.notifier});

  final MasterIntakeExecuting state;
  final MasterDrawerStage drawerStage;
  final MasterIntakeNotifier notifier;

  bool get _isOpened => drawerStage is MasterDrawerOpened;

  @override
  Widget build(BuildContext context) {
    final job = state.currentJob;
    if (job == null) return const SizedBox.shrink();

    final isLocked = !_isOpened || state.isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormHeader(state: state, job: job, isOpened: _isOpened),
        const SizedBox(height: 12),
        Expanded(
          child: Opacity(
            opacity: isLocked ? 0.55 : 1.0,
            child: IgnorePointer(
              ignoring: isLocked,
              child: job.isKubik
                  ? _KubikBody(state: state, notifier: notifier)
                  : _UnitDoseBody(state: state, notifier: notifier),
            ),
          ),
        ),
        Divider(height: 1, color: MedColors.border2),
        _FormFooter(
          canConfirm: _canConfirm(job) && _isOpened,
          isSaving: state.isSaving,
          isKubik: job.isKubik,
          isLastCubicCell: job.isKubik && state.currentTargetIndex >= job.targets.length - 1,
          onConfirm: notifier.confirmCurrent,
        ),
      ],
    );
  }

  bool _canConfirm(IntakeDrawerJob job) {
    if (job.isKubik) {
      final t = state.currentTarget;
      return t != null && t.isValid;
    }
    return job.canComplete;
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.state, required this.job, required this.isOpened});

  final MasterIntakeExecuting state;
  final IntakeDrawerJob job;
  final bool isOpened;

  @override
  Widget build(BuildContext context) {
    final slot = job.representativeAssignment.drawerUnit?.drawerSlot;
    final address = slot?.address ?? '?';

    final String title;
    final String subtitle;
    if (job.isKubik) {
      final t = state.currentTarget;
      title = t?.medicine?.name ?? '—';
      subtitle = context.l10n.refill_label_cellProgress(state.currentTargetIndex + 1, job.targets.length);
    } else {
      final distinct = job.distinctMedicineCount;
      title = distinct == 1
          ? (job.representativeAssignment.medicine?.name ?? '—')
          : context.l10n.intake_label_multiMedicine(distinct);
      subtitle = context.l10n.refill_chip_drawer(address);
    }

    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(title, style: MedTextStyles.titleSm(), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(subtitle, style: MedTextStyles.monoXs(color: MedColors.text3)),
            ],
          ),
        ),
        _DrawerStatePill(isOpened: isOpened),
      ],
    );
  }
}

class _DrawerStatePill extends StatelessWidget {
  const _DrawerStatePill({required this.isOpened});

  final bool isOpened;

  @override
  Widget build(BuildContext context) {
    return MedInfoChip(
      backgroundColor: isOpened ? MedColors.greenLight : MedColors.amberLight,
      foregroundColor: isOpened ? MedColors.green : MedColors.amber,
      info: isOpened ? context.l10n.refill_status_drawerOpen : context.l10n.refill_status_drawerOpening,
    );
  }
}

class _KubikBody extends StatelessWidget {
  const _KubikBody({required this.state, required this.notifier});

  final MasterIntakeExecuting state;
  final MasterIntakeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final target = state.currentTarget;
    if (target == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: _TargetCountCard(
        target: target,
        onCountChanged: (detailIndex, v) => notifier.onCubicCountChanged(detailIndex, v),
      ),
    );
  }
}

class _UnitDoseBody extends StatelessWidget {
  const _UnitDoseBody({required this.state, required this.notifier});

  final MasterIntakeExecuting state;
  final MasterIntakeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final job = state.currentJob;
    if (job == null) return const SizedBox.shrink();

    return ListView.separated(
      itemCount: job.targets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, targetIndex) {
        final target = job.targets[targetIndex];
        return _TargetCountCard(
          target: target,
          onCountChanged: (detailIndex, v) => notifier.onStepCountChanged(targetIndex, detailIndex, v),
        );
      },
    );
  }
}

/// Bir hedefin (ilaç) sayım kartı. Alınan miktar + CountType'a göre sayım girişi.
class _TargetCountCard extends StatelessWidget {
  const _TargetCountCard({required this.target, required this.onCountChanged});

  final IntakeTarget target;

  /// (detailIndex, value) — hedefin detayları içindeki indekse göre.
  final void Function(int detailIndex, double? value) onCountChanged;

  static double? _parseQty(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return double.tryParse(raw.trim().replaceAll(',', '.'));
  }

  @override
  Widget build(BuildContext context) {
    final unit = target.medicine?.operationUnit ?? context.l10n.refillList_defaultUnitFallback;
    final showCensus = target.needsCount;

    return Container(
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  target.medicine?.name ?? '—',
                  style: MedTextStyles.titleSm(color: MedColors.text2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                context.l10n.intake_label_takenAmount(target.totalDose.formatFractional, unit),
                style: MedTextStyles.monoMd(color: MedColors.blue),
              ),
            ],
          ),
          if (showCensus)
            ...target.details.asMap().entries.map((entry) {
              final i = entry.key;
              final detail = entry.value;
              return _CensusRow(
                index: target.details.length > 1 ? i + 1 : null,
                value: detail.censusQuantity,
                unit: unit,
                onChanged: (v) => onCountChanged(i, _parseQty(v)),
              );
            }),
        ],
      ),
    );
  }
}

class _CensusRow extends StatelessWidget {
  const _CensusRow({required this.index, required this.value, required this.unit, required this.onChanged});

  final int? index;
  final double? value;
  final String unit;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        if (index != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.smAll),
            child: Text('$index', style: MedTextStyles.monoSm(color: MedColors.blue)),
          ),
        Expanded(
          child: MedTextInputField(
            label: context.l10n.intake_label_countFieldLabel(unit),
            initialValue: value.formatFractional,
            keyboardType: TextInputType.number,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _FormFooter extends StatelessWidget {
  const _FormFooter({
    required this.canConfirm,
    required this.isSaving,
    required this.isKubik,
    required this.isLastCubicCell,
    required this.onConfirm,
  });

  final bool canConfirm;
  final bool isSaving;
  final bool isKubik;
  final bool isLastCubicCell;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final label = (isKubik && !isLastCubicCell) ? context.l10n.refill_action_nextCell : context.l10n.intake_action_complete;
    final hint = (isKubik && !isLastCubicCell)
        ? context.l10n.intake_hint_nextCellOpens
        : context.l10n.intake_hint_confirmCloses;

    return Padding(
      padding: MedSpacing.insetMd,
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: Text(hint, style: MedTextStyles.bodySm(color: MedColors.text3)),
          ),
          MedButton(label: label, isLoading: isSaving, onPressed: canConfirm ? onConfirm : null),
        ],
      ),
    );
  }
}
