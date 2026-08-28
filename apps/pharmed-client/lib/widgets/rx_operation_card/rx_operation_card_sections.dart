part of 'rx_operation_card_2.dart';

// ─────────────────────────────────────────────────────────────────
// RxOperationCard — private bölüm widget'ları
// ─────────────────────────────────────────────────────────────────

/// Header: checkbox + ad + (doz · barkod) + durum chip'i.
/// Zemin: seçili → surface, seçili değil → surface2 (tasarım v2).
class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.title,
    required this.subtitle,
    required this.barcode,
    required this.isSelected,
    required this.statusChip,
    required this.showCheckbox,
  });

  final String title;
  final String? subtitle;
  final String? barcode;
  final bool isSelected;
  final RxCardChip? statusChip;
  final bool showCheckbox;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: 13),
      decoration: BoxDecoration(
        color: isSelected ? MedColors.surface : MedColors.surface2,
        border: const Border(bottom: BorderSide(color: MedColors.border2)),
        borderRadius: BorderRadius.only(topLeft: MedRadius.midAll.topLeft, topRight: MedRadius.midAll.topRight),
      ),
      child: Row(
        spacing: MedSpacing.md,
        children: [
          if (showCheckbox) _SelectionBox(isSelected: isSelected),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 3,
              children: [
                Text(
                  title,
                  style: MedTextStyles.titleMd(color: isSelected ? MedColors.blue : MedColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null || barcode != null)
                  Row(
                    spacing: MedSpacing.md,
                    children: [
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: MedTextStyles.monoMd(color: MedColors.text2).copyWith(fontWeight: FontWeight.bold),
                        ),
                      if (subtitle != null && barcode != null) const _DotSeparator(),
                      if (barcode != null)
                        Flexible(
                          child: Text(
                            barcode!,
                            style: MedTextStyles.monoMd(color: MedColors.text4),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          if (statusChip != null) _StatusChip(chip: statusChip!),
        ],
      ),
    );
  }
}

/// 22px seçim kutusu — seçili: mavi dolgu + beyaz check.
class _SelectionBox extends StatelessWidget {
  const _SelectionBox({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isSelected ? MedColors.blue : MedColors.surface,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: 1.5),
      ),
      child: isSelected ? Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), size: 13, color: Colors.white) : null,
    );
  }
}

class _DotSeparator extends StatelessWidget {
  const _DotSeparator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(color: MedColors.text4, shape: BoxShape.circle),
    );
  }
}

/// Sağ üst durum chip'i — pill biçimli, semantic tondan renklenir.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.chip});

  final RxCardChip chip;

  @override
  Widget build(BuildContext context) {
    final c = MedSemanticColors.of(chip.tone);
    return MedChip(label: chip.label, background: c.background, foreground: c.foreground, shape: MedChipShape.pill);
  }
}

/// Hasta bağlam satırı: kişi ikonu + ad + oda chip'i.
class _PatientRow extends StatelessWidget {
  const _PatientRow({required this.patient});

  final RxCardPatient patient;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 7,
      children: [
        Icon(PhosphorIcons.user(), size: 13, color: MedColors.text3),
        Flexible(
          child: Text(
            patient.name,
            style: MedTextStyles.bodySm(color: MedColors.text2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (patient.room != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(color: MedColors.surface3, borderRadius: BorderRadius.circular(20)),
            child: Text(patient.room!, style: MedTextStyles.monoXs(color: MedColors.text3)),
          ),
      ],
    );
  }
}

/// RFID / uygunluk kontrolü durum satırı.
class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.data});

  final RxCardStatusRow data;

  @override
  Widget build(BuildContext context) {
    final sem = data.tone != null ? MedSemanticColors.of(data.tone!) : null;
    final bg = sem?.background ?? MedColors.surface3;
    final fg = sem?.foreground ?? MedColors.text3;

    return Container(
      constraints: const BoxConstraints(minHeight: MedSpacing.touchTarget),
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: MedSpacing.md),
      decoration: BoxDecoration(color: bg, borderRadius: MedRadius.mdAll),
      child: Row(
        spacing: MedSpacing.md,
        children: [
          if (data.leadingIcon != null) Icon(data.leadingIcon, size: 14, color: fg),
          Expanded(
            child: Text(
              data.leadingText,
              style: MedTextStyles.monoSm(color: fg),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (data.trailingLabel != null || data.indicator != RxCardIndicator.none)
            Row(
              spacing: 6,
              children: [
                switch (data.indicator) {
                  RxCardIndicator.spinner => SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  ),
                  RxCardIndicator.check => Icon(
                    PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                    size: 14,
                    color: fg,
                  ),
                  RxCardIndicator.warn => Icon(
                    PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
                    size: 14,
                    color: fg,
                  ),
                  RxCardIndicator.none => const SizedBox.shrink(),
                },
                if (data.trailingLabel != null)
                  Text(
                    data.trailingLabel!,
                    style: MedTextStyles.bodySm(color: fg, weight: FontWeight.w600),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Şahit satırı. Onay bekliyorsa satırın tamamı tıklanabilirdir
/// (44px dokunmatik hedef kuralı) ve sağda aksiyon butonu görünür.
class _WitnessRow extends StatelessWidget {
  const _WitnessRow({required this.data});

  final RxCardWitness data;

  @override
  Widget build(BuildContext context) {
    final sem = MedSemanticColors.of(data.isConfirmed ? MedTone.success : MedTone.warning);
    final isPending = !data.isConfirmed;

    return InkWell(
      onTap: isPending ? data.onTap : null,
      borderRadius: MedRadius.mdAll,
      child: Container(
        constraints: const BoxConstraints(minHeight: MedSpacing.touchTarget),
        padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: MedSpacing.md),
        decoration: BoxDecoration(
          color: sem.background,
          borderRadius: MedRadius.mdAll,
          border: Border.all(color: sem.border(alpha: 0.5)),
        ),
        child: Row(
          spacing: MedSpacing.md,
          children: [
            Icon(PhosphorIcons.user(), size: 16, color: sem.foreground),
            Expanded(
              child: Text(
                data.label,
                style: MedTextStyles.bodySm(color: sem.foreground, weight: FontWeight.w600),
              ),
            ),
            if (data.isConfirmed && data.confirmedName != null)
              Icon(PhosphorIcons.checkCircle(), size: 18, color: sem.foreground),
            if (isPending && data.actionLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: sem.foreground,
                  borderRadius: MedRadius.mdAll,
                  boxShadow: MedShadows.sm,
                ),
                child: Text(
                  data.actionLabel!,
                  style: MedTextStyles.bodySm(color: Colors.white, weight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "Son Hareketler" bloğu — başlık şeridi + hareket satırları.
class _MovementsBlock extends StatelessWidget {
  const _MovementsBlock({required this.movements});

  final List<RxCardMovement> movements;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: 7),
            decoration: const BoxDecoration(
              color: MedColors.surface2,
              border: Border(bottom: BorderSide(color: MedColors.border2)),
            ),
            child: Text(
              'Son Hareketler',
              //'context.l10n.rxOperationCard_movementsHeader',
              style: MedTextStyles.monoMd(color: MedColors.text3),
            ),
          ),
          for (final (i, m) in movements.indexed) _MovementRow(movement: m, showDivider: i > 0),
        ],
      ),
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement, required this.showDivider});

  final RxCardMovement movement;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final fg = MedSemanticColors.of(movement.tone).foreground;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: 9),
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: showDivider ? const Border(top: BorderSide(color: MedColors.border2)) : null,
      ),
      child: Row(
        spacing: MedSpacing.md,
        children: [
          Text(
            movement.label,
            style: MedTextStyles.monoSm(color: fg).copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Expanded(
            child: Text(
              movement.performedBy,
              style: MedTextStyles.bodySm(color: MedColors.text2).copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            movement.quantity,
            style: MedTextStyles.monoSm(color: MedColors.text).copyWith(fontWeight: FontWeight.w500),
          ),
          Text(movement.date, style: MedTextStyles.monoSm(color: MedColors.text4)),
        ],
      ),
    );
  }
}

/// Etiketli not bloğu (örn. iade notu).
class _NoteBlock extends StatelessWidget {
  const _NoteBlock({required this.note});

  final RxCardNote note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: MedSpacing.md),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 3,
        children: [
          Text(
            note.label,
            style: MedTextStyles.monoSm(color: MedColors.text3).copyWith(fontWeight: FontWeight.bold),
          ),
          Text(note.text, style: MedTextStyles.bodySm(color: MedColors.text2)),
        ],
      ),
    );
  }
}

/// Miktar satırı — "MİKTAR" etiketi + [MedDoseStepper.compact].
/// Satıra dokunuşlar karta iletilmez (kart seçimi bozulmasın diye).
class _StepperRow extends StatelessWidget {
  const _StepperRow({required this.data});

  final RxCardStepper data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // dokunuşu yut — karttaki InkWell'e taşma
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: MedSpacing.md),
        decoration: BoxDecoration(
          color: MedColors.surface2,
          borderRadius: MedRadius.mdAll,
          border: Border.all(color: MedColors.border2),
        ),
        child: Row(
          children: [
            Text(context.l10n.census_extraStockQuantityLabel, style: MedTextStyles.monoXs(color: MedColors.text3)),
            const Spacer(),
            MedDoseStepper.compact(
              value: data.value,
              unit: data.unit,
              onChanged: data.onChanged,
              max: data.max ?? 999,
              step: data.step,
            ),
          ],
        ),
      ),
    );
  }
}

/// Alt meta satırı: saat (sol) + konum (sağ).
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.time, required this.location});

  final String? time;
  final String? location;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (time != null)
          Row(
            spacing: 5,
            children: [
              Icon(PhosphorIcons.clock(), size: 11, color: MedColors.text4),
              Text(time!, style: MedTextStyles.monoXs(color: MedColors.text4)),
            ],
          ),
        const Spacer(),
        if (location != null) Text(location!, style: MedTextStyles.monoXs(color: MedColors.text4)),
      ],
    );
  }
}
