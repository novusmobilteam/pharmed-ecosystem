// Reçete kalemlerini gruplu gösteren açılır kartlar.
//
// [SWREQ-UI-RX-DETAIL-CARD-001]
// Sınıf : Class A
//
// İki gruplama:
//   • RxGroupCard     — tek reçete (başlık: reçete no + tarih)
//   • RxDayGroupCard  — tek gün (başlık: tarih + gün adı + Bugün/Dün rozeti);
//                       satırda saat sütunu ve kalemin reçete numarası görünür.
//
// Yapı:
//   _RxCardShell
//   ├── _RxCardHeader          (ikon · başlık/alt başlık · rozet · kalem sayısı · ok)
//   └── AnimatedSize
//       └── _RxItemRow × N     (dokununca hareket detayı açılır)
//
// Kullanım:
//   RxGroupCard(prescription: rx, items: items)
//   RxDayGroupCard(day: date, items: items)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pharmed_client/core/providers/usecase_providers.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'widgets.dart';

// ── Reçete bazlı ───────────────────────────────────────────────────────────

class RxGroupCard extends StatelessWidget {
  const RxGroupCard({super.key, required this.prescription, required this.items, this.initiallyExpanded = true});

  final Prescription prescription;

  /// Bu reçeteye ait kalemler — dışarıdan filtrelenmiş olarak gelir.
  final List<PrescriptionItem> items;

  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final date = prescription.prescriptionDate;
    return _RxCardShell(
      icon: PhosphorIcons.prescription(),
      title: context.l10n.rxGroup_headerTitle(prescription.id ?? '—'),
      subtitle: date?.formattedDate,
      itemCount: items.length,
      initiallyExpanded: initiallyExpanded,
      items: items,
      showTime: false,
      showPrescriptionRef: false,
    );
  }
}

// ── Gün bazlı ──────────────────────────────────────────────────────────────

class RxDayGroupCard extends StatelessWidget {
  const RxDayGroupCard({super.key, required this.day, required this.items, this.initiallyExpanded = true});

  /// Grubun günü (saat bileşeni yok sayılır). null → tarihi bilinmeyen kalemler.
  final DateTime? day;

  /// O güne ait kalemler, saate göre sıralı.
  final List<PrescriptionItem> items;

  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final d = day;
    final locale = Localizations.localeOf(context).toString();

    String? badge;
    if (d != null) {
      final today = todayDateOnly();
      final dayOnly = DateTime(d.year, d.month, d.day);
      if (dayOnly == today) {
        badge = context.l10n.dateFilter_todayPreset;
      } else if (dayOnly == today.subtract(const Duration(days: 1))) {
        badge = context.l10n.dateFilter_yesterday;
      } else if (dayOnly == today.add(const Duration(days: 1))) {
        badge = context.l10n.dateFilter_tomorrowPreset;
      }
    }

    return _RxCardShell(
      icon: PhosphorIcons.calendarBlank(),
      title: d == null ? '—' : DateFormat('d MMMM y', locale).format(d),
      subtitle: d == null ? null : DateFormat('EEEE', locale).format(d),
      badge: badge,
      itemCount: items.length,
      initiallyExpanded: initiallyExpanded,
      items: items,
      showTime: true,
      showPrescriptionRef: true,
    );
  }
}

// ── Ortak kart iskeleti ────────────────────────────────────────────────────

class _RxCardShell extends StatefulWidget {
  const _RxCardShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.itemCount,
    required this.initiallyExpanded,
    required this.items,
    required this.showTime,
    required this.showPrescriptionRef,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final int itemCount;
  final bool initiallyExpanded;
  final List<PrescriptionItem> items;
  final bool showTime;
  final bool showPrescriptionRef;

  @override
  State<_RxCardShell> createState() => _RxCardShellState();
}

class _RxCardShellState extends State<_RxCardShell> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    // Kenarlık foregroundDecoration'da: içerik (başlığın zemini) köşelerde
    // kenarlığın üstüne boyanıp onu kesmesin diye kenarlık en üste çizilir.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        boxShadow: _expanded ? MedShadows.sm : null,
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: _expanded ? MedColors.blueMid : MedColors.border),
        borderRadius: MedRadius.lgAll,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _RxCardHeader(
            icon: widget.icon,
            title: widget.title,
            subtitle: widget.subtitle,
            badge: widget.badge,
            itemCount: widget.itemCount,
            expanded: _expanded,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < widget.items.length; i++) ...[
                        if (i > 0) const Divider(height: 1, indent: MedSpacing.xl, endIndent: MedSpacing.xl),
                        _RxItemRow(
                          item: widget.items[i],
                          showTime: widget.showTime,
                          showPrescriptionRef: widget.showPrescriptionRef,
                        ),
                      ],
                      const SizedBox(height: MedSpacing.sm),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _RxCardHeader extends StatelessWidget {
  const _RxCardHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.itemCount,
    required this.expanded,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final int itemCount;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.lg),
        decoration: BoxDecoration(
          color: expanded ? MedColors.surface2 : MedColors.surface,
          border: expanded ? const Border(bottom: BorderSide(color: MedColors.border2)) : null,
        ),
        child: Row(
          spacing: MedSpacing.lg,
          children: [
            MedRectangleIconButton(color: MedColors.blueLight, iconColor: MedColors.blue, iconData: icon, size: 38),
            Expanded(
              child: Column(
                spacing: 2.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: MedSpacing.md,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MedTextStyles.titleMd(color: MedColors.text),
                        ),
                      ),
                      if (badge != null)
                        MedChip(label: badge!, style: MedChipStyle.info, size: MedChipSize.sm, mono: false),
                    ],
                  ),
                  if (subtitle != null) Text(subtitle!, style: MedTextStyles.bodySm(color: MedColors.text3)),
                ],
              ),
            ),
            MedChip(
              label: context.l10n.rxGroup_itemCountBadge(itemCount),
              size: MedChipSize.sm,
              shape: MedChipShape.pill,
              mono: false,
            ),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(PhosphorIcons.caretDown(), size: 18, color: MedColors.text3),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Kalem satırı ───────────────────────────────────────────────────────────

class _RxItemRow extends ConsumerStatefulWidget {
  const _RxItemRow({required this.item, required this.showTime, required this.showPrescriptionRef});

  final PrescriptionItem item;

  /// true → solda saat sütunu (gün bazlı kart); false → saat chip olarak sağda.
  final bool showTime;

  /// true → ilaç adının altında kalemin reçete numarası (gün bazlı kart).
  final bool showPrescriptionRef;

  @override
  ConsumerState<_RxItemRow> createState() => _RxItemRowState();
}

class _RxItemRowState extends ConsumerState<_RxItemRow> {
  bool _detailExpanded = false;
  bool _isLoading = false;
  bool _hasLoaded = false;
  List<PrescriptionItemMovement>? _movements;

  Future<void> _loadMovements() async {
    if (_hasLoaded || _isLoading) return;
    final itemId = widget.item.id;
    if (itemId == null) return;

    setState(() => _isLoading = true);

    final useCase = ref.read(getPrescriptionItemMovementsUseCaseProvider);
    final result = await useCase.call(itemId);
    if (!mounted) return;

    result.when(
      ok: (movements) {
        setState(() {
          _movements = movements;
          _isLoading = false;
          _hasLoaded = true;
        });
      },
      error: (_) {
        setState(() => _isLoading = false);
      },
    );
  }

  static String _hhmm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final status = item.status;
    final time = item.time;
    final accent = status?.foregroundColor ?? MedColors.border;

    final subParts = <String>[
      if (item.medicine?.barcode != null) item.medicine!.barcode!,
      if (widget.showPrescriptionRef && item.prescriptionId != null)
        context.l10n.rxGroup_headerTitle(item.prescriptionId!),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => setState(() => _detailExpanded = !_detailExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.lg),
            child: Row(
              spacing: MedSpacing.lg,
              children: [
                if (widget.showTime)
                  SizedBox(
                    width: 52,
                    child: Text(
                      time == null ? '—' : _hhmm(time),
                      style: MedTextStyles.monoMd(color: MedColors.text, weight: FontWeight.w700),
                    ),
                  ),
                // Durum rengiyle ince şerit — listede durum bir bakışta okunur.
                Container(
                  width: 3,
                  height: 36,
                  decoration: BoxDecoration(color: accent, borderRadius: MedRadius.smAll),
                ),
                Expanded(
                  child: Column(
                    spacing: 2.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.medicine?.name ?? '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: MedTextStyles.titleSm(color: MedColors.text),
                      ),
                      if (subParts.isNotEmpty)
                        Text(
                          subParts.join('  ·  '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MedTextStyles.monoSm(color: MedColors.text3),
                        ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 6.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (item.dosePiece != null) MedDoseChip(item: item),
                    if (!widget.showTime && time != null) MedTimeChip(time: time),
                    if (status != null)
                      MedInfoChip(
                        info: status.label(context),
                        backgroundColor: status.backgroundColor,
                        foregroundColor: status.foregroundColor,
                      ),
                  ],
                ),
                AnimatedRotation(
                  turns: _detailExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(PhosphorIcons.caretDown(), size: 16, color: MedColors.text4),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _detailExpanded
              ? Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(MedSpacing.xl, 0, MedSpacing.xl, MedSpacing.lg),
                  padding: MedSpacing.insetLg,
                  decoration: BoxDecoration(
                    color: MedColors.surface2,
                    borderRadius: MedRadius.mdAll,
                    border: Border.all(color: MedColors.border2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: MedSpacing.md,
                    children: [
                      RxMovementBlock(
                        lastMovement: item.lastMovement,
                        medicine: item.medicine,
                        movements: _movements,
                        isLoading: _isLoading,
                      ),
                      if (!_hasLoaded)
                        TextButton(
                          onPressed: _loadMovements,
                          child: Text(context.l10n.movement_showAll, style: MedTextStyles.bodyMd(color: MedColors.blue)),
                        ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
