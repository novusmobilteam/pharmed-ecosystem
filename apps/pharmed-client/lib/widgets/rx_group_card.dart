// Reçete detay kartı — açılıp kapanan, ilaç kalemleri carousel içinde gösterilir.
//
// [SWREQ-UI-RX-DETAIL-CARD-001]
// Sınıf : Class A
//
// Yapı:
//   PrescriptionDetailCard
//   ├── _RxCardHeader          (reçete no · doktor · tarih · kalem sayısı · chevron)
//   └── AnimatedSize
//       └── Column
//           └── _RxItemRow × N
//               └── _RxItemDetail   (expandable — max 2 block/satır)
//                   └── _DetailBlock × N
//
// Kullanım:
//   PrescriptionDetailCard(
//     prescription: rx,
//     items: items,                    // Bu reçeteye ait PrescriptionItem'lar
//     initiallyExpanded: true,
//   )

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/providers/usecase_providers.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'widgets.dart';

class RxGroupCard extends StatefulWidget {
  const RxGroupCard({super.key, required this.prescription, required this.items, this.initiallyExpanded = true});

  final Prescription prescription;

  /// Bu reçeteye ait kalemler — dışarıdan filtrelenmiş olarak gelir.
  final List<PrescriptionItem> items;

  final bool initiallyExpanded;

  @override
  State<RxGroupCard> createState() => _RxGroupCardState();
}

class _RxGroupCardState extends State<RxGroupCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border, width: 1),
        borderRadius: MedRadius.lgAll,
        boxShadow: MedShadows.sm,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          _RxCardHeader(
            prescription: widget.prescription,
            itemCount: widget.items.length,
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
                        if (i > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl4),
                            child: MedDottedDivider(),
                          ),
                        _RxItemRow(item: widget.items[i]),
                      ],
                      const SizedBox(height: MedSpacing.md),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _RxCardHeader extends StatelessWidget {
  const _RxCardHeader({
    required this.prescription,
    required this.itemCount,
    required this.expanded,
    required this.onTap,
  });

  final Prescription prescription;
  final int itemCount;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = prescription.prescriptionDate;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl4, vertical: MedSpacing.xl),
        decoration: BoxDecoration(
          color: MedColors.surface2,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(MedRadius.lgAll.topLeft.x),
            topRight: Radius.circular(MedRadius.lgAll.topLeft.x),
          ),
          border: Border(bottom: BorderSide(color: MedColors.border2, width: 1)),
        ),
        child: Row(
          spacing: 12,
          children: [
            MedRectangleIcon(
              backgroundColor: MedColors.blueLight,
              foregroundColor: MedColors.blue,
              icon: PhosphorIcons.prescription(),
            ),
            Expanded(
              child: Column(
                spacing: 4.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#${prescription.id ?? '—'}', style: MedTextStyles.titleMd()),
                  if (date != null) ...[Text(date.formattedDate, style: MedTextStyles.monoMd())],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RxItemRow extends ConsumerStatefulWidget {
  const _RxItemRow({required this.item});

  final PrescriptionItem item;

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

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final status = item.status;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl4, vertical: MedSpacing.xl2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _detailExpanded = !_detailExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    spacing: 2.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.medicine?.name ?? '—', style: MedTextStyles.titleLg()),
                      if (item.medicine?.barcode != null)
                        Text(item.medicine!.barcode!, style: MedTextStyles.monoMd(color: MedColors.text4)),
                    ],
                  ),
                ),
                Row(
                  spacing: 6.0,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status != null) ...[
                      const SizedBox(height: MedSpacing.xs),
                      MedInfoChip(
                        info: status.label,
                        backgroundColor: status.backgroundColor,
                        foregroundColor: status.foregroundColor,
                      ),
                    ],
                    if (item.dosePiece != null) MedDoseChip(item: item),
                    if (item.time != null) MedTimeChip(time: item.time!),
                  ],
                ),
              ],
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _detailExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 12.0),
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
                            child: Text(context.l10n.movement_showAll, style: MedTextStyles.bodyMd(color: MedColors.text3)),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
