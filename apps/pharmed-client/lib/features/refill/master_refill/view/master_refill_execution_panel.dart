// pharmed-client/lib/features/refill/master_refill/presentation/view/master_refill_execution_panel.dart
//
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
import 'package:phosphor_flutter/phosphor_flutter.dart';

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

    if (executing == null) return const _CompletedView();

    final notifier = ref.read(masterRefillNotifierProvider.notifier);
    final drawerStage = ref.watch(masterDrawerSessionProvider).stage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProgressBar(state: executing, onStop: notifier.stopQueue),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: 300, child: _QueueList(state: executing)),
              const SizedBox(width: 12),
              Expanded(
                child: _ActiveForm(state: executing, drawerStage: drawerStage, notifier: notifier),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── İlerleme çubuğu ──────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.state, required this.onStop});

  final MasterRefillExecuting state;
  final Future<void> Function() onStop;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Text(context.l10n.refill_title_autoRefill, style: MedTextStyles.titleSm()),
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
        MedButton(
          label: context.l10n.refill_action_stop,
          //icon: PhosphorIcons.x(),
          variant: MedButtonVariant.danger,
          size: MedButtonSize.sm,
          onPressed: () => onStop(),
        ),
      ],
    );
  }
}

// ── Kuyruk listesi (çekmece + kübik alt-adımlar) ───────────────────────────────

class _QueueList extends StatelessWidget {
  const _QueueList({required this.state});

  final MasterRefillExecuting state;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: state.jobs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final job = state.jobs[index];
        final isActive = index == state.currentIndex;
        return _QueueItem(job: job, isActive: isActive, activeTargetIndex: isActive ? state.currentTargetIndex : -1);
      },
    );
  }
}

class _QueueItem extends StatelessWidget {
  const _QueueItem({required this.job, required this.isActive, required this.activeTargetIndex});

  final RefillDrawerJob job;
  final bool isActive;
  final int activeTargetIndex;

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor, statusLabel, statusColor) = switch (job.status) {
      RefillJobStatus.completed => (
        PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
        MedColors.green,
        context.l10n.refill_status_done,
        MedColors.green,
      ),
      RefillJobStatus.active => (
        PhosphorIcons.package(PhosphorIconsStyle.fill),
        MedColors.blue,
        context.l10n.refill_status_open,
        MedColors.blue,
      ),
      RefillJobStatus.pending => (
        PhosphorIcons.clock(),
        MedColors.text3,
        context.l10n.refill_status_queued,
        MedColors.text3,
      ),
      RefillJobStatus.failed => (
        PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
        MedColors.red,
        context.l10n.refill_status_failed,
        MedColors.red,
      ),
    };

    final slot = job.representativeAssignment.drawerUnit?.drawerSlot;
    final address = slot?.address ?? '?';
    final isDimmed = job.status == RefillJobStatus.completed || job.status == RefillJobStatus.failed;

    // Kübik çekmecede aktifken alt-adımları (gözleri) göster.
    final showSubSteps = isActive && job.isKubik && job.targets.length > 1;

    return Opacity(
      opacity: isDimmed ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: isActive ? MedColors.blue : MedColors.border, width: isActive ? 2 : 1),
          borderRadius: MedRadius.mdAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              child: Row(
                spacing: 8,
                children: [
                  Icon(icon, size: 18, color: iconColor),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          _drawerTitle(context, job, address),
                          style: MedTextStyles.bodySm(color: MedColors.text, weight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _drawerSubtitle(context, job, address),
                          style: MedTextStyles.monoXs(color: MedColors.text3),
                        ),
                      ],
                    ),
                  ),
                  Text(statusLabel, style: MedTextStyles.monoXs(color: statusColor)),
                ],
              ),
            ),
            if (showSubSteps) ...[
              Divider(height: 1, color: MedColors.border2),
              Padding(
                padding: const EdgeInsets.fromLTRB(11, 8, 11, 10),
                child: Column(
                  spacing: 6,
                  children: List.generate(job.targets.length, (i) {
                    return _SubStepRow(target: job.targets[i], index: i, activeIndex: activeTargetIndex);
                  }),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _drawerTitle(BuildContext context, RefillDrawerJob job, String address) {
    final distinct = job.distinctMedicineCount;
    if (distinct == 1) {
      return job.representativeAssignment.medicine?.name ?? context.l10n.refill_chip_drawer(address);
    }
    return context.l10n.refill_label_multiMedicine(distinct);
  }

  String _drawerSubtitle(BuildContext context, RefillDrawerJob job, String address) {
    return job.isKubik
        ? context.l10n.refill_subtitle_kubikCells(address, job.targets.length)
        : context.l10n.refill_chip_drawer(address);
  }
}

/// Kübik çekmecenin tek bir gözünün (lid) alt-adım satırı.
class _SubStepRow extends StatelessWidget {
  const _SubStepRow({required this.target, required this.index, required this.activeIndex});

  final RefillFillTarget target;
  final int index;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final isDone = index < activeIndex;
    final isActive = index == activeIndex;

    final (icon, color) = isDone
        ? (PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), MedColors.green)
        : isActive
        ? (PhosphorIcons.dotOutline(PhosphorIconsStyle.fill), MedColors.blue)
        : (PhosphorIcons.circle(), MedColors.text4);

    final cellNo = target.unit?.orderNo ?? target.unit?.compartmentNo ?? (index + 1);
    final medName = target.assignment.medicine?.name ?? '—';

    return Row(
      spacing: 7,
      children: [
        Icon(icon, size: 15, color: color),
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? MedColors.blueLight : MedColors.surface2,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text('$cellNo', style: MedTextStyles.monoXs(color: isActive ? MedColors.blue : MedColors.text3)),
        ),
        Expanded(
          child: Text(
            medName,
            style: MedTextStyles.bodySm(
              color: isActive ? MedColors.text : MedColors.text3,
              weight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FormHeader(state: state, job: job, isOpened: _isOpened),
          Divider(height: 1, color: MedColors.border2),
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
      ),
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
  const _FormHeader({required this.state, required this.job, required this.isOpened});

  final MasterRefillExecuting state;
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

    return Padding(
      padding: MedSpacing.insetMd,
      child: Row(
        spacing: 10,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.mdAll),
            child: Icon(
              job.isKubik ? PhosphorIcons.squaresFour() : PhosphorIcons.rows(),
              size: 19,
              color: MedColors.blue,
            ),
          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: MedRadius.mdAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Icon(isOpened ? PhosphorIcons.lockOpen() : PhosphorIcons.lock(), size: 14, color: color),
          Text(
            isOpened ? context.l10n.refill_status_drawerOpen : context.l10n.refill_status_drawerOpening,
            style: MedTextStyles.bodySm(color: color),
          ),
        ],
      ),
    );
  }
}

// ── Kübik gövde (tek aktif göz) ────────────────────────────────────────────────

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
      padding: MedSpacing.insetMd,
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

// ── Birim doz gövde (tüm step'ler) ────────────────────────────────────────────

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
      padding: MedSpacing.insetMd,
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

// ── Göz input kartı (ortak) ────────────────────────────────────────────────────

class _CellInputCard extends StatelessWidget {
  const _CellInputCard({
    required this.assignment,
    required this.current,
    required this.countQuantity,
    required this.fillingQuantity,
    required this.miadDate,
    required this.onCountChanged,
    required this.onFillingChanged,
    required this.onMiadChanged,
    this.stepLabel,
  });

  final MedicineAssignment assignment;
  final double current;
  final double countQuantity;
  final double fillingQuantity;
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
    final hasFilling = fillingQuantity > 0;
    final needsMiad = hasFilling && miadDate == null;

    final maxQty = assignment.maxQuantityFromBackend;
    final critQty = assignment.critQuantityFromBackend;
    final minQty = assignment.minQuantityFromBackend;

    Color stockColor = MedColors.green;
    if (current <= critQty) {
      stockColor = MedColors.red;
    } else if (current <= minQty) {
      stockColor = MedColors.amber;
    }

    return Container(
      padding: MedSpacing.insetXl,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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

// ── Tamamlandı ───────────────────────────────────────────────────────────────

class _CompletedView extends StatelessWidget {
  const _CompletedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), size: 48, color: MedColors.green),
          Text(context.l10n.refill_success_completedMaster, style: MedTextStyles.titleMd()),
        ],
      ),
    );
  }
}
