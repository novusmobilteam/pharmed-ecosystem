// [SWREQ-CLI-MREFILL-006] [IEC 62304 §5.5]
// FAZ 2 — Otomatik dolum kuyruğunun işlendiği panel.
//
// Sol: çekmece kuyruğu. Aktif kübik çekmecenin altında hedef gözler (lid'ler)
//      alt-adım olarak açılır; lid-by-lid ilerleme buradan izlenir.
// Sağ: aktif formun gösterimi:
//      - Kübik: yalnızca o an açık olan TEK gözün formu (lid-by-lid).
//      - Birim doz/standart: çekmecenin tüm gözleri tek formda.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../notifier/master_refill_notifier.dart';
import '../notifier/master_refill_state.dart';

class MasterRefillExecutionPanel extends ConsumerWidget {
  const MasterRefillExecutionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterRefillNotifierProvider);

    final executing = switch (state) {
      MasterRefillExecuting e => e,
      MasterRefillError(previousState: MasterRefillExecuting e) => e,
      _ => null,
    };

    // Yürütme yoksa (seçim fazı veya boş) yönlendirici boş state.
    if (executing == null) {
      return EmptyStateWidget(title: context.l10n.refill_hint_idleExecution);
    }
    final notifier = ref.read(masterRefillNotifierProvider.notifier);
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

// ── İlerleme çubuğu ──────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.state});

  final MasterRefillExecuting state;

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

// ── Aktif form ─────────────────────────────────────────────────────────────────

class _ActiveForm extends StatelessWidget {
  const _ActiveForm({required this.state, required this.drawerStage, required this.notifier});

  final MasterRefillExecuting state;
  final MasterDrawerStage drawerStage;
  final MasterRefillNotifier notifier;

  bool get _isOpened => drawerStage is MasterDrawerOpened;

  @override
  Widget build(BuildContext context) {
    final job = state.currentJob;
    if (job == null) return const SizedBox.shrink();

    final isLocked = !_isOpened || state.isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormHeader(state: state, job: job, isOpened: _isOpened, assignment: state.currentTarget?.assignment),
        SizedBox(height: 12.0),
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
          onConfirm: () => notifier.confirmCurrent(),
        ),
      ],
    );
  }

  bool _canConfirm(RefillDrawerJob job) {
    if (job.isKubik) {
      final t = state.currentTarget;
      return t != null && t.isValid;
    }
    return job.canComplete;
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.state, this.assignment, required this.job, required this.isOpened});

  final MasterRefillExecuting state;
  final MedicineAssignment? assignment;
  final RefillDrawerJob job;
  final bool isOpened;

  @override
  Widget build(BuildContext context) {
    final slot = job.representativeAssignment.drawerUnit?.drawerSlot;
    final address = slot?.address ?? '?';

    // Kübikte aktif gözün adı + lid ilerleme (Göz 2/4); birimdozda çekmece başlığı.
    final String title;
    final String subtitle;
    if (job.isKubik) {
      final t = state.currentTarget;
      title = t?.assignment.medicine?.name ?? '—';
      subtitle = context.l10n.refill_label_cellProgress(state.currentTargetIndex + 1, job.targets.length);
    } else {
      final distinct = job.distinctMedicineCount;
      title = distinct == 1
          ? (job.representativeAssignment.medicine?.name ?? '—')
          : context.l10n.refill_label_multiMedicine(distinct);
      subtitle = context.l10n.refill_chip_drawer(address);
    }

    final maxQty = assignment?.maxQuantityFromBackend;
    final critQty = assignment?.critQuantityFromBackend;
    final minQty = assignment?.minQuantityFromBackend;

    return Column(
      spacing: 10,
      children: [
        Row(
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
        ),
        Row(
          spacing: 8,
          children: [
            _ThresholdInline(
              label: context.l10n.refill_label_min,
              value: minQty.formatFractional,
              color: MedColors.text2,
            ),
            _ThresholdInline(
              label: context.l10n.refill_label_critical,
              value: critQty.formatFractional,
              color: MedColors.red,
            ),
            _ThresholdInline(
              label: context.l10n.refill_label_max,
              value: maxQty.formatFractional,
              color: MedColors.text2,
            ),
          ],
        ),
      ],
    );
  }
}

class _DrawerStatePill extends StatelessWidget {
  const _DrawerStatePill({required this.isOpened});

  final bool isOpened;

  @override
  Widget build(BuildContext context) {
    final color = isOpened ? MedColors.green : MedColors.amber;
    final bg = isOpened ? MedColors.greenLight : MedColors.amberLight;
    return MedInfoChip(
      backgroundColor: bg,
      foregroundColor: color,
      info: isOpened ? context.l10n.refill_status_drawerOpen : context.l10n.refill_status_drawerOpening,
    );
  }
}

class _KubikBody extends StatelessWidget {
  const _KubikBody({required this.state, required this.notifier});

  final MasterRefillExecuting state;
  final MasterRefillNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final target = state.currentTarget;
    final ti = state.currentTargetIndex;
    if (target == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: _CellInputCard(
        assignment: target.assignment,
        current: target.currentQuantity,
        countQuantity: target.cubicCount,
        fillingQuantity: target.cubicFilling,
        miadDate: target.cubicMiad,
        onCountChanged: (v) => notifier.onCubicCountChanged(ti, v),
        onFillingChanged: (v) => notifier.onCubicFillingChanged(ti, v),
        onMiadChanged: (d) => notifier.onCubicMiadChanged(ti, d),
      ),
    );
  }
}

class _UnitDoseBody extends StatelessWidget {
  const _UnitDoseBody({required this.state, required this.notifier});

  final MasterRefillExecuting state;
  final MasterRefillNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final target = state.currentTarget;
    if (target == null) return const SizedBox.shrink();
    const ti = 0; // birim dozda job içinde tek target

    return ListView.separated(
      itemCount: target.steps.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, stepIndex) {
        final step = target.steps[stepIndex];
        return _CellInputCard(
          assignment: target.assignment,
          stepLabel: context.l10n.refill_label_cellNo(stepIndex + 1),
          current: target.assignment.toDisplayQuantity(step.countQuantity),
          countQuantity: step.countQuantity,
          fillingQuantity: step.fillingQuantity,
          miadDate: step.miadDate,
          onCountChanged: (v) => notifier.onStepCountChanged(ti, stepIndex, v),
          onFillingChanged: (v) => notifier.onStepFillingChanged(ti, stepIndex, v),
          onMiadChanged: (d) => notifier.onStepMiadChanged(ti, stepIndex, d),
        );
      },
    );
  }
}

class _CellInputCard extends StatelessWidget {
  const _CellInputCard({
    required this.assignment,
    required this.current,
    this.countQuantity,
    this.fillingQuantity,
    required this.miadDate,
    required this.onCountChanged,
    required this.onFillingChanged,
    required this.onMiadChanged,
    this.stepLabel,
  });

  final MedicineAssignment assignment;
  final double current;
  final double? countQuantity;
  final double? fillingQuantity;
  final DateTime? miadDate;
  final ValueChanged<double> onCountChanged;
  final ValueChanged<double> onFillingChanged;
  final ValueChanged<DateTime?> onMiadChanged;

  /// Birim doz gözünde "1. Göz" etiketi; kübikte null.
  final String? stepLabel;

  static double _parseQty(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0;
    return double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final hasFilling = (fillingQuantity ?? 0) > 0;
    final needsMiad = hasFilling && miadDate == null;

    final critQty = assignment.critQuantityFromBackend;
    final minQty = assignment.minQuantityFromBackend;

    Color stockColor = MedColors.green;
    if (current <= critQty) {
      stockColor = MedColors.red;
    } else if (current <= minQty) {
      stockColor = MedColors.amber;
    }

    return Container(
      padding: MedSpacing.insetXl * 1.5,
      decoration: BoxDecoration(
        border: Border.all(color: needsMiad ? MedColors.amber : MedColors.border),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            spacing: 8,
            children: [
              if (stepLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.smAll),
                  child: Text(stepLabel!, style: MedTextStyles.monoSm(color: MedColors.blue)),
                ),
              Expanded(
                child: Text(
                  assignment.medicine?.name ?? '—',
                  style: MedTextStyles.titleSm(color: MedColors.text2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                context.l10n.refill_label_current(current.formatFractional),
                style: MedTextStyles.monoMd(color: stockColor),
              ),
            ],
          ),

          Row(
            spacing: 8,
            children: [
              Expanded(
                child: MedTextInputField(
                  label: context.l10n.refill_label_countQty,
                  initialValue: countQuantity.formatFractional,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => onCountChanged(_parseQty(v)),
                ),
              ),
              Expanded(
                child: MedTextInputField(
                  label: context.l10n.refill_label_fillQty,
                  initialValue: fillingQuantity.formatFractional,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => onFillingChanged(_parseQty(v)),
                ),
              ),
              SizedBox(
                width: 220,
                child: MedDateInputField(
                  label: context.l10n.refill_label_expiryDate,
                  initialValue: miadDate,
                  onDateSelected: onMiadChanged,
                  firstDate: DateTime.now(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThresholdInline extends StatelessWidget {
  const _ThresholdInline({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(color: MedColors.surface2, borderRadius: MedRadius.smAll),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: MedTextStyles.monoSm(color: MedColors.text4)),
            Text(value, style: MedTextStyles.monoMd(color: color)),
          ],
        ),
      ),
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
    // Kübikte ara gözlerde "Sonraki göz", son gözde/birimdozda "Dolumu tamamla".
    final label = (isKubik && !isLastCubicCell)
        ? context.l10n.refill_action_nextCell
        : context.l10n.refill_action_completeFilling;
    final hint = (isKubik && !isLastCubicCell)
        ? context.l10n.refill_hint_nextCellOpens
        : context.l10n.refill_hint_confirmCloses;

    return Padding(
      padding: MedSpacing.insetMd,
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: Text(hint, style: MedTextStyles.bodySm(color: MedColors.text3)),
          ),
          MedButton(
            label: label,
            //icon: (isKubik && !isLastCubicCell) ? PhosphorIcons.arrowRight() : PhosphorIcons.check(),
            isLoading: isSaving,
            onPressed: canConfirm ? onConfirm : null,
          ),
        ],
      ),
    );
  }
}
