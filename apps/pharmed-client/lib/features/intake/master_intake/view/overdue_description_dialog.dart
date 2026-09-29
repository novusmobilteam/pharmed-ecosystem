// [SWREQ-CLI-INTAKE-OVERDUE-001]
// Uygulama saati geçmiş ilaçlar için alım öncesi açıklama dialogu.
// Sonuç: itemId → açıklama. İptal edilirse null döner.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../auth/auth.dart';
import '../notifier/overdue_description_dialog_notifier.dart';

Future<Map<int, String>?> showOverdueDescriptionDialog(
  BuildContext context, {
  required List<IntakeItem> items,
  Hospitalization? hospitalization,
}) {
  return showMedDialog<Map<int, String>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => OverdueDescriptionDialog(items: items, hospitalization: hospitalization),
  );
}

class OverdueDescriptionDialog extends ConsumerStatefulWidget {
  const OverdueDescriptionDialog({super.key, required this.items, this.hospitalization});

  final List<IntakeItem> items;
  final Hospitalization? hospitalization;

  @override
  ConsumerState<OverdueDescriptionDialog> createState() => _OverdueDescriptionDialogState();
}

class _OverdueDescriptionDialogState extends ConsumerState<OverdueDescriptionDialog> {
  final _textController = TextEditingController();
  int _syncedRevision = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(overdueDescriptionDialogNotifierProvider).init(widget.items);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Editör içeriği dışarıdan değiştiyse controller'ı senkronla.
  void _syncEditor(OverdueDescriptionDialogNotifier n) {
    if (_syncedRevision == n.editorRevision) return;
    _syncedRevision = n.editorRevision;
    final text = n.activeEntry.text;
    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = ref.watch(overdueDescriptionDialogNotifierProvider);
    _syncEditor(n);

    final user = ref.read(authNotifierProvider.notifier).currentUser;
    final l10n = context.l10n;

    return MedDialog(
      width: 1060,
      maxHeightFactor: 0.9,
      padded: false,
      icon: PhosphorIcons.clockCountdown(),
      title: l10n.intake_overdue_dialogTitle,
      subtitle: l10n.intake_overdue_dialogSubtitle(widget.items.length),
      headerTrailing: user == null ? null : _AuthorizedUserBadge(user: user),
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ModeBar(notifier: n, hospitalization: widget.hospitalization),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 340, child: _ItemList(notifier: n)),
                Expanded(
                  child: _Editor(notifier: n, controller: _textController),
                ),
              ],
            ),
          ),
          _Footer(
            notifier: n,
            onCancel: () => Navigator.of(context).pop(),
            onConfirm: () => Navigator.of(context).pop(n.buildResult()),
          ),
        ],
      ),
    );
  }
}

// ── Header: yetkili kullanıcı rozeti ────────────────────────────────────

class _AuthorizedUserBadge extends StatelessWidget {
  const _AuthorizedUserBadge({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: MedColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: MedSpacing.md,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: MedColors.blue, shape: BoxShape.circle),
            child: Text(user.initials, style: MedTextStyles.bodySm(color: Colors.white)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(user.fullName, style: MedTextStyles.bodySm(color: MedColors.text)),
              Text(
                '${context.l10n.intake_overdue_authorizedBadge} · ${user.roleName}',
                style: MedTextStyles.monoXs(color: MedColors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Mod çubuğu ──────────────────────────────────────────────────────────

class _ModeBar extends StatelessWidget {
  const _ModeBar({required this.notifier, this.hospitalization});

  final OverdueDescriptionDialogNotifier notifier;
  final Hospitalization? hospitalization;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final patientName = hospitalization?.patient?.fullName;
    final roomName = hospitalization?.bed?.room?.name ?? hospitalization?.room?.name;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        spacing: MedSpacing.xl,
        children: [
          Text(l10n.intake_overdue_modeLabel.toUpperCase(), style: MedTextStyles.monoXs(color: MedColors.text3)),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: MedColors.surface3, borderRadius: MedRadius.midAll),
            child: Row(
              spacing: 4,
              children: [
                _ModeSegment(
                  icon: PhosphorIcons.rows(),
                  label: l10n.intake_overdue_modeSame,
                  selected: notifier.isSame,
                  onTap: () => notifier.setMode(OverdueDescriptionMode.same),
                ),
                _ModeSegment(
                  icon: PhosphorIcons.listBullets(),
                  label: l10n.intake_overdue_modeEach,
                  selected: !notifier.isSame,
                  onTap: () => notifier.setMode(OverdueDescriptionMode.each),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (patientName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: MedColors.surface2,
                borderRadius: MedRadius.mdAll,
                border: Border.all(color: MedColors.border),
              ),
              child: Text(
                roomName == null ? patientName : '$patientName · $roomName',
                style: MedTextStyles.monoSm(color: MedColors.text2),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  const _ModeSegment({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? MedColors.blue : MedColors.text2;
    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.mdAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: MedSpacing.touchTarget,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? MedColors.surface : Colors.transparent,
          borderRadius: MedRadius.mdAll,
          boxShadow: selected ? MedShadows.sm : null,
        ),
        child: Row(
          spacing: MedSpacing.md,
          children: [
            Icon(icon, size: 18, color: color),
            Text(label, style: MedTextStyles.bodyMd(color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Sol: kalem listesi ──────────────────────────────────────────────────

class _ItemList extends StatelessWidget {
  const _ItemList({required this.notifier});

  final OverdueDescriptionDialogNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
      decoration: const BoxDecoration(
        color: MedColors.surface2,
        border: Border(right: BorderSide(color: MedColors.border2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: MedSpacing.lg,
        children: [
          Text(
            l10n.intake_overdue_itemsLabel(notifier.items.length).toUpperCase(),
            style: MedTextStyles.monoXs(color: MedColors.text3),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: notifier.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _ItemRow(
                notifier: notifier,
                item: notifier.items[i],
                active: !notifier.isSame && notifier.activeIndex == i,
                onTap: () => notifier.focusItem(i),
              ),
            ),
          ),
          if (notifier.isSame)
            Text(l10n.intake_overdue_tapToCustomizeHint, style: MedTextStyles.bodySm(color: MedColors.text3)),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.notifier, required this.item, required this.active, required this.onTap});

  final OverdueDescriptionDialogNotifier notifier;
  final IntakeItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entry = notifier.entryFor(item);
    final value = notifier.valueOf(entry);
    final ok = value != null;

    final (statusText, statusColor, statusBg) = switch ((ok, notifier.isSame)) {
      (true, true) => (l10n.intake_overdue_statusShared, MedColors.blue, MedColors.blueLight),
      (true, false) => (l10n.intake_overdue_statusEntered, MedColors.green, MedColors.greenLight),
      _ => (l10n.intake_overdue_statusPending, MedColors.amber, MedColors.amberLight),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.midAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: MedSpacing.insetLg,
        decoration: BoxDecoration(
          color: active ? MedColors.blueLight : MedColors.surface,
          borderRadius: MedRadius.midAll,
          border: Border.all(color: active ? MedColors.blue : MedColors.border, width: active ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: MedSpacing.md,
              children: [
                Expanded(child: Text(item.medicine?.name ?? '—', style: MedTextStyles.titleSm())),
                _MonoTag(
                  text:
                      '${(item.dosePiece ?? 0).formatFractional} '
                      '${item.medicine?.operationUnitLocalized(context) ?? l10n.common_defaultUnitFallback}',
                ),
              ],
            ),
            _OverdueTimeTag(time: item.time),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(color: statusBg, borderRadius: MedRadius.smAll),
              child: Row(
                spacing: 6,
                children: [
                  Icon(
                    ok ? PhosphorIcons.check(PhosphorIconsStyle.bold) : PhosphorIcons.clock(),
                    size: 14,
                    color: statusColor,
                  ),
                  Text(statusText, style: MedTextStyles.bodySm(color: statusColor)),
                  if (ok)
                    Expanded(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: MedTextStyles.bodySm(color: MedColors.text2),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonoTag extends StatelessWidget {
  const _MonoTag({required this.text, this.color = MedColors.text2, this.background = MedColors.surface3});

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: background, borderRadius: MedRadius.smAll),
      child: Text(text, style: MedTextStyles.monoXs(color: color)),
    );
  }
}

/// Planlanan uygulama saati + ne kadar geçtiği.
class _OverdueTimeTag extends StatelessWidget {
  const _OverdueTimeTag({required this.time});

  final DateTime? time;

  @override
  Widget build(BuildContext context) {
    final t = time;
    if (t == null) return const SizedBox.shrink();

    final diff = DateTime.now().difference(t);
    final overdue = diff.isNegative ? Duration.zero : diff;

    return _MonoTag(
      text:
          '${context.l10n.intake_overdue_scheduledAt(t.formattedDateTime)} · '
          '${context.l10n.intake_overdue_overdueBy(overdue.inHours, overdue.inMinutes.remainder(60))}',
      color: MedColors.red,
      background: MedColors.redLight,
    );
  }
}

// ── Sağ: editör ─────────────────────────────────────────────────────────

class _Editor extends StatelessWidget {
  const _Editor({required this.notifier, required this.controller});

  final OverdueDescriptionDialogNotifier notifier;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final active = notifier.activeItem;

    final title = notifier.isSame ? l10n.intake_overdue_sharedEditorTitle : (active?.medicine?.name ?? '—');
    final subtitle = notifier.isSame
        ? l10n.intake_overdue_sharedEditorSubtitle(notifier.items.length)
        : (active?.time == null ? '' : l10n.intake_overdue_scheduledAt(active!.time!.formattedDateTime));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: MedSpacing.xl,
        children: [
          // Başlık + (each modunda) gezinme
          Row(
            spacing: MedSpacing.lg,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(title, style: MedTextStyles.titleMd()),
                    if (subtitle.isNotEmpty) Text(subtitle, style: MedTextStyles.bodySm(color: MedColors.text3)),
                  ],
                ),
              ),
              if (!notifier.isSame) ...[
                MedButton(
                  label: l10n.intake_overdue_applyToRemaining,
                  size: MedButtonSize.sm,
                  variant: MedButtonVariant.secondary,
                  onPressed: notifier.canApplyToRemaining ? notifier.applyToRemaining : null,
                ),
                _NavButton(icon: PhosphorIcons.caretLeft(), onTap: notifier.canGoPrev ? notifier.goPrev : null),
                Text(
                  '${notifier.activeIndex + 1} / ${notifier.items.length}',
                  style: MedTextStyles.monoSm(color: MedColors.text2),
                ),
                _NavButton(icon: PhosphorIcons.caretRight(), onTap: notifier.canGoNext ? notifier.goNext : null),
              ],
            ],
          ),

          // Ön tanımlı açıklamalar
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              Text(l10n.intake_overdue_presetsLabel.toUpperCase(), style: MedTextStyles.monoXs(color: MedColors.text3)),
              _PresetGrid(notifier: notifier),
            ],
          ),

          // Ayraç
          Row(
            spacing: MedSpacing.lg,
            children: [
              const Expanded(child: Divider(color: MedColors.border2, height: 1)),
              Text(l10n.intake_overdue_orWriteNew.toUpperCase(), style: MedTextStyles.monoXs(color: MedColors.text3)),
              const Expanded(child: Divider(color: MedColors.border2, height: 1)),
            ],
          ),

          // Serbest metin
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: MedSpacing.md,
            children: [
              Text(
                l10n.intake_overdue_descriptionLabel.toUpperCase(),
                style: MedTextStyles.monoXs(color: MedColors.text3),
              ),
              _DescriptionField(controller: controller, onChanged: notifier.onTextChanged),
              Row(
                spacing: MedSpacing.lg,
                children: [
                  Expanded(child: _HintText(notifier: notifier)),
                  Text(
                    '${notifier.activeEntry.text.length}/${OverdueDescriptionDialogNotifier.maxLength}',
                    style: MedTextStyles.monoXs(color: MedColors.text3),
                  ),
                  MedButton(
                    label: l10n.intake_overdue_addPreset,
                    size: MedButtonSize.sm,
                    variant: MedButtonVariant.secondary,
                    onPressed: notifier.canAddPreset
                        ? () => notifier.addActiveTextAsPreset(
                            onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.mdAll,
      child: Container(
        width: MedSpacing.touchTarget,
        height: MedSpacing.touchTarget,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MedColors.surface,
          borderRadius: MedRadius.mdAll,
          border: Border.all(color: MedColors.border),
        ),
        child: Icon(icon, size: 18, color: enabled ? MedColors.text2 : MedColors.text4),
      ),
    );
  }
}

class _PresetGrid extends StatelessWidget {
  const _PresetGrid({required this.notifier});

  final OverdueDescriptionDialogNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (notifier.isLoading(notifier.fetchPresetsOp)) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: MedLoadingIndicator()),
      );
    }
    if (notifier.isFailed(notifier.fetchPresetsOp)) {
      return Row(
        spacing: MedSpacing.lg,
        children: [
          Expanded(
            child: Text(
              notifier.message(notifier.fetchPresetsOp) ?? '',
              style: MedTextStyles.bodySm(color: MedColors.red),
            ),
          ),
          MedButton(
            label: l10n.common_retryButton,
            size: MedButtonSize.sm,
            variant: MedButtonVariant.secondary,
            onPressed: notifier.fetchPresets,
          ),
        ],
      );
    }
    if (notifier.presets.isEmpty) {
      return Text(l10n.intake_overdue_presetsEmpty, style: MedTextStyles.bodySm(color: MedColors.text3));
    }

    final selectedId = notifier.activeEntry.presetId;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chipWidth = (constraints.maxWidth - MedSpacing.md) / 2;
        return Wrap(
          spacing: MedSpacing.md,
          runSpacing: MedSpacing.md,
          children: [
            for (final preset in notifier.presets)
              SizedBox(
                width: chipWidth,
                child: _PresetChip(
                  text: preset.description ?? '',
                  selected: preset.id != null && preset.id == selectedId,
                  isNew: notifier.isNewPreset(preset.id),
                  onTap: preset.id == null ? null : () => notifier.togglePreset(preset.id!),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.text, required this.selected, required this.isNew, this.onTap});

  final String text;
  final bool selected;
  final bool isNew;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.midAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? MedColors.blueLight : MedColors.surface,
          borderRadius: MedRadius.midAll,
          border: Border.all(color: selected ? MedColors.blue : MedColors.border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          spacing: MedSpacing.lg,
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? MedColors.blue : MedColors.border, width: 2),
              ),
              child: selected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: MedColors.blue, shape: BoxShape.circle),
                    )
                  : null,
            ),
            Expanded(
              child: Text(text, style: MedTextStyles.bodyMd(color: selected ? MedColors.blue : MedColors.text)),
            ),
            if (isNew)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: MedColors.greenLight, borderRadius: BorderRadius.circular(20)),
                child: Text(context.l10n.intake_overdue_newBadge, style: MedTextStyles.monoXs(color: MedColors.green)),
              ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, [double w = 1.5]) => OutlineInputBorder(
      borderRadius: MedRadius.mdAll,
      borderSide: BorderSide(color: c, width: w),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      minLines: 3,
      maxLines: 4,
      maxLength: OverdueDescriptionDialogNotifier.maxLength,
      style: MedTextStyles.bodyMd(color: MedColors.text),
      decoration: InputDecoration(
        hintText: context.l10n.intake_overdue_descriptionPlaceholder,
        hintStyle: MedTextStyles.bodyMd(color: MedColors.text4),
        counterText: '', // sayaç editörün altında ayrıca gösteriliyor
        filled: true,
        fillColor: MedColors.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: border(MedColors.border),
        focusedBorder: border(MedColors.blue),
      ),
    );
  }
}

class _HintText extends StatelessWidget {
  const _HintText({required this.notifier});

  final OverdueDescriptionDialogNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const min = OverdueDescriptionDialogNotifier.minLength;

    final (text, warn) = switch (notifier.hint) {
      OverdueDescriptionHint.presetSelected => (l10n.intake_overdue_hintPresetSelected, false),
      OverdueDescriptionHint.tooShort => (l10n.intake_overdue_hintMinLength(min), true),
      OverdueDescriptionHint.alreadyPreset => (l10n.intake_overdue_hintAlreadyPreset, false),
      OverdueDescriptionHint.canSaveAsPreset => (l10n.intake_overdue_hintCanSave, false),
      OverdueDescriptionHint.idle => (l10n.intake_overdue_hintDefault(min), false),
    };

    return Text(text, style: MedTextStyles.bodySm(color: warn ? MedColors.amber : MedColors.text3));
  }
}

// ── Footer ──────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({required this.notifier, required this.onCancel, required this.onConfirm});

  final OverdueDescriptionDialogNotifier notifier;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = notifier.isComplete
        ? l10n.intake_overdue_progressComplete
        : l10n.intake_overdue_progress(notifier.validCount, notifier.items.length);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: MedColors.surface,
        border: Border(top: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        spacing: MedSpacing.xl,
        children: [
          Icon(PhosphorIcons.shieldCheck(), size: 18, color: MedColors.text3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(progress, style: MedTextStyles.bodyMd(color: MedColors.text)),
                Text(l10n.intake_overdue_auditNote, style: MedTextStyles.bodySm(color: MedColors.text3)),
              ],
            ),
          ),
          MedButton(label: l10n.intake_overdue_cancelButton, variant: MedButtonVariant.secondary, onPressed: onCancel),
          SizedBox(
            width: 200,
            child: MedButton(
              label: l10n.intake_overdue_confirmButton,
              variant: MedButtonVariant.primary,
              onPressed: notifier.isComplete ? onConfirm : null,
            ),
          ),
        ],
      ),
    );
  }
}
