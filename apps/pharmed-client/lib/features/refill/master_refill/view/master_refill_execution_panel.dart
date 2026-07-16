// [SWREQ-CLI-MREFILL-006] [IEC 62304 §5.5]
// FAZ 2 — Otomatik dolum kuyruğunun işlendiği tam-ekran yürütme akışı.
//
// HMI tek-iş prensibi: her an ekranda TEK bir adım vardır.
//   1. Çekmece açılıyor      → MasterDrawerOpening / WaitingForPull / OpeningLid
//   2. Göz doldurma formu     → MasterDrawerOpened
//        - Kübik: yalnızca o an açık TEK gözün formu (lid-by-lid), üstte nokta
//          göstergeleri + "Göz 2/4".
//        - Birim doz/standart: çekmecenin tüm gözleri tek listede.
//
// Sayısal girişler (sayım / eklenecek) numpad-tetikleyen kartlardır; miad
// MedDateInputField ile seçilir.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/cabin_operation/master_drawer/master_drawer_session_notifier.dart';
import 'package:pharmed_client/core/cabin_operation/master_drawer/master_drawer_stage.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
    if (executing == null) return const SizedBox.shrink();

    final notifier = ref.read(masterRefillNotifierProvider.notifier);
    final drawerStage = ref.watch(masterDrawerSessionProvider).stage;

    // Çekmece henüz açık değilse: tam-ekran bekleme adımı.
    // Opened olur olmaz otomatik olarak forma geçilir (ara "Devam" ekranı yok).
    final isOpened = drawerStage is MasterDrawerOpened;

    final job = executing.currentJob;
    if (job == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TopStrip(state: executing, onStop: notifier.stopQueue),
        const SizedBox(height: 20),
        Expanded(
          child: isOpened
              ? _FillForm(state: executing, job: job, notifier: notifier)
              : _DrawerOpeningView(stage: drawerStage, job: job),
        ),
      ],
    );
  }
}

// ── Üst şerit: genel ilerleme + Durdur ─────────────────────────────────────────

class _TopStrip extends StatelessWidget {
  const _TopStrip({required this.state, required this.onStop});

  final MasterRefillExecuting state;
  final Future<void> Function() onStop;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Text(
          context.l10n.refill_label_queueProgress(state.completedJobs + 1, state.totalJobs),
          style: MedTextStyles.bodySm(color: MedColors.text2),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 8,
              backgroundColor: MedColors.border2,
              valueColor: const AlwaysStoppedAnimation(MedColors.blue),
            ),
          ),
        ),
        MedButton(
          label: context.l10n.refill_action_stop,
          variant: MedButtonVariant.secondary,
          size: MedButtonSize.sm,
          onPressed: () => _confirmStop(context),
        ),
      ],
    );
  }

  Future<void> _confirmStop(BuildContext context) async {
    MessageUtils.showConfirmDialog(
      context: context,
      action: ConfirmAction.custom,
      customTitle: context.l10n.refill_stop_confirmTitle,
      customMessage: context.l10n.refill_stop_confirmMessage,
      iconData: PhosphorIcons.warning(),
      color: MedColors.red,
      confirmButtonText: context.l10n.refill_stop_confirmYes,
      cancelButtonText: context.l10n.common_cancelButton,
      onConfirm: onStop,
    );
  }
}

// ── Çekmece açılıyor (tam ekran bekleme) ───────────────────────────────────────

class _DrawerOpeningView extends StatelessWidget {
  const _DrawerOpeningView({required this.stage, required this.job});

  final MasterDrawerStage stage;
  final RefillDrawerJob job;

  @override
  Widget build(BuildContext context) {
    final slot = job.representativeAssignment.drawerUnit?.drawerSlot;
    final address = slot?.address ?? '?';

    final (String title, String subtitle) = switch (stage) {
      MasterDrawerWaitingForPull() => (
        context.l10n.refill_status_waitingPullTitle,
        context.l10n.refill_status_waitingPullBody,
      ),
      MasterDrawerOpeningLid() => (
        context.l10n.refill_status_openingLidTitle,
        context.l10n.refill_status_openingLidBody,
      ),
      _ => (context.l10n.refill_status_openingTitle, context.l10n.refill_status_openingBody),
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: [
          Container(
            width: 120,
            height: 90,
            decoration: BoxDecoration(
              border: Border.all(color: MedColors.blue, width: 2.5),
              borderRadius: MedRadius.lgAll,
            ),
            alignment: Alignment.center,
            child: Icon(PhosphorIcons.package(), size: 46, color: MedColors.blue),
          ),
          Text(title, style: MedTextStyles.titleLg()),
          Text(context.l10n.refill_chip_drawer(address), style: MedTextStyles.monoSm(color: MedColors.blue)),
          Text(
            subtitle,
            style: MedTextStyles.bodyMd(color: MedColors.text3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }
}

// ── Göz doldurma formu (çekmece açıkken) ───────────────────────────────────────

class _FillForm extends StatelessWidget {
  const _FillForm({required this.state, required this.job, required this.notifier});

  final MasterRefillExecuting state;
  final RefillDrawerJob job;
  final MasterRefillNotifier notifier;

  @override
  Widget build(BuildContext context) {
    // Birim dozda 6'dan çok göz grid'e geçer ve daha geniş alan ister;
    // kübik ve kısa birim doz tek sütun kaldığından dar form daha okunaklı.
    final isWideGrid = !job.isKubik && job.targets.isNotEmpty && job.targets.first.steps.length > 6;
    final maxWidth = isWideGrid ? 1100.0 : 640.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FormHeader(state: state, job: job),
            const SizedBox(height: 20),
            Expanded(
              child: Opacity(
                opacity: state.isSaving ? 0.55 : 1.0,
                child: IgnorePointer(
                  ignoring: state.isSaving,
                  child: job.isKubik
                      ? _KubikBody(state: state, notifier: notifier)
                      : _UnitDoseBody(state: state, notifier: notifier),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _FooterButton(state: state, job: job, onConfirm: notifier.confirmCurrent),
          ],
        ),
      ),
    );
  }
}

// ── Form başlığı: kübikte lid ilerlemesi + nokta göstergeleri ───────────────────

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.state, required this.job});

  final MasterRefillExecuting state;
  final RefillDrawerJob job;

  @override
  Widget build(BuildContext context) {
    final slot = job.representativeAssignment.drawerUnit?.drawerSlot;
    final address = slot?.address ?? '?';

    if (!job.isKubik) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(context.l10n.refill_chip_drawer(address), style: MedTextStyles.bodySm(color: MedColors.text2)),
          Text(context.l10n.refill_title_fillCells, style: MedTextStyles.titleMd()),
        ],
      );
    }

    // Kübik: lid ilerlemesi + nokta göstergeleri.
    final total = job.targets.length;
    final active = state.currentTargetIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.refill_chip_drawer(address), style: MedTextStyles.bodySm(color: MedColors.text2)),
            Text(
              context.l10n.refill_label_cellProgress(active + 1, total),
              style: MedTextStyles.bodySm(color: MedColors.blue),
            ),
          ],
        ),
        Row(
          spacing: 6,
          children: List.generate(total, (i) {
            final color = i < active
                ? MedColors.blue
                : i == active
                ? MedColors.blue
                : MedColors.border2;
            return Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Kübik gövde: tek gözün formu ────────────────────────────────────────────────

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
      child: _RefillCellCard(
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

// ── Birim doz gövde: tüm gözler listede ─────────────────────────────────────────

class _UnitDoseBody extends StatelessWidget {
  const _UnitDoseBody({required this.state, required this.notifier});

  final MasterRefillExecuting state;
  final MasterRefillNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final target = state.currentTarget;
    if (target == null) return const SizedBox.shrink();
    const ti = 0; // birim dozda job içinde tek target

    Widget cardFor(int stepIndex) {
      final step = target.steps[stepIndex];
      return _RefillCellCard(
        assignment: target.assignment,
        density: MedCellDensity.compact,
        stepLabel: context.l10n.refill_label_cellNo(stepIndex + 1),
        current: target.assignment.toDisplayQuantity(step.countQuantity),
        countQuantity: step.countQuantity,
        fillingQuantity: step.fillingQuantity,
        miadDate: step.miadDate,
        onCountChanged: (v) => notifier.onStepCountChanged(ti, stepIndex, v),
        onFillingChanged: (v) => notifier.onStepFillingChanged(ti, stepIndex, v),
        onMiadChanged: (d) => notifier.onStepMiadChanged(ti, stepIndex, d),
      );
    }

    final count = target.steps.length;

    // 6 veya daha az: tek sütun liste. Fazlaysa: genişliğe sığan kadar sütunlu grid.
    if (count <= 6) {
      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) => cardFor(i),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const targetWidth = 440.0;
        const gap = 12.0;
        final columns = (constraints.maxWidth / (targetWidth + gap)).floor().clamp(2, 3);
        final cardWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: List.generate(count, (i) => SizedBox(width: cardWidth, child: cardFor(i))),
          ),
        );
      },
    );
  }
}

// ── Dolum ekranına özel adapter: MedicineAssignment → ortak MedCellInputCard ────
//
// Domain değerlerini (stok, eşik, isMeasureUnit) türetip domain-bağımsız
// MedCellInputCard'a besler; numpad açmayı ve miad date field'ı burada kurar.

class _RefillCellCard extends StatelessWidget {
  const _RefillCellCard({
    required this.assignment,
    required this.current,
    this.countQuantity,
    this.fillingQuantity,
    required this.miadDate,
    required this.onCountChanged,
    required this.onFillingChanged,
    required this.onMiadChanged,
    this.stepLabel,
    this.density = MedCellDensity.comfortable,
  });

  final MedicineAssignment assignment;
  final double current;
  final double? countQuantity;
  final double? fillingQuantity;
  final DateTime? miadDate;
  final ValueChanged<double> onCountChanged;
  final ValueChanged<double> onFillingChanged;
  final ValueChanged<DateTime?> onMiadChanged;
  final String? stepLabel;
  final MedCellDensity density;

  static double _parseQty(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0;
    return double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0;
  }

  Future<void> _openNumpad({
    required BuildContext context,
    required double? currentValue,
    required ValueChanged<double> onChanged,
  }) async {
    final result = await showNumpadView(context, initialValue: currentValue.formatFractional);
    if (result != null) onChanged(_parseQty(result));
  }

  Future<void> _openMiadPicker(BuildContext context) async {
    // TODO(imza): projedeki özel tarih seçici ile değiştir. showNumpadView
    // gibi bir showDatePickerView varsa onu çağır. Şimdilik native picker.
    final picked = await showDatePicker(
      context: context,
      initialDate: miadDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2099, 12, 31),
    );
    if (picked != null) onMiadChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hasFilling = (fillingQuantity ?? 0) > 0;
    final needsMiad = hasFilling && miadDate == null;

    final critQty = assignment.critQuantityFromBackend;
    final minQty = assignment.minQuantityFromBackend;
    final maxQty = assignment.maxQuantityFromBackend;

    final MedCellStockLevel level;
    if (current <= critQty) {
      level = MedCellStockLevel.critical;
    } else if (current <= minQty) {
      level = MedCellStockLevel.low;
    } else {
      level = MedCellStockLevel.ok;
    }

    final miadText = miadDate == null ? context.l10n.dateField_placeholder : miadDate.formattedDate;

    return MedCellInputCard(
      density: density,
      title: assignment.medicine?.name ?? '—',
      stepLabel: stepLabel,
      current: current.formatFractional,
      max: maxQty.formatFractional,
      fillRatio: maxQty > 0 ? (current / maxQty).clamp(0.0, 1.0) : 0.0,
      stockLevel: level,
      countLabel: context.l10n.refill_label_countQty,
      countText: countQuantity.formatFractional,
      countPlaceholder: (countQuantity ?? 0) == 0,
      onCountTap: () => _openNumpad(context: context, currentValue: countQuantity, onChanged: onCountChanged),
      fillingLabel: context.l10n.refill_label_fillQty,
      fillingText: fillingQuantity.formatFractional,
      fillingPlaceholder: (fillingQuantity ?? 0) == 0,
      onFillingTap: () => _openNumpad(context: context, currentValue: fillingQuantity, onChanged: onFillingChanged),
      miadLabel: context.l10n.refill_label_expiryDate,
      miadText: miadText,
      miadPlaceholder: miadDate == null,
      miadHasError: needsMiad,
      miadIcon: PhosphorIcons.calendarBlank(),
      onMiadTap: () => _openMiadPicker(context),
    );
  }
}

// ── Alt buton: kübik ara/son göz veya birim doz tamamla ─────────────────────────

class _FooterButton extends StatelessWidget {
  const _FooterButton({required this.state, required this.job, required this.onConfirm});

  final MasterRefillExecuting state;
  final RefillDrawerJob job;
  final Future<void> Function() onConfirm;

  bool get _canConfirm {
    if (job.isKubik) {
      final t = state.currentTarget;
      return t != null && t.isValid;
    }
    return job.canComplete;
  }

  @override
  Widget build(BuildContext context) {
    final isLastCubicCell = job.isKubik && state.currentTargetIndex >= job.targets.length - 1;
    final label = (job.isKubik && !isLastCubicCell)
        ? context.l10n.refill_action_nextCell
        : context.l10n.refill_action_completeFilling;

    return SizedBox(
      width: double.infinity,
      child: MedButton(
        label: label,
        size: MedButtonSize.lg,
        isLoading: state.isSaving,
        onPressed: _canConfirm ? () => onConfirm() : null,
      ),
    );
  }
}
