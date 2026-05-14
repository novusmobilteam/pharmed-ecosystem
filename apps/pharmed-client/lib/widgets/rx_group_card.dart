// lib/features/prescription/widgets/prescription_detail_card.dart
//
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
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: MedColors.border2,
                            indent: MedSpacing.xl4,
                            endIndent: MedSpacing.xl4,
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

class _RxItemRow extends StatefulWidget {
  const _RxItemRow({required this.item});

  final PrescriptionItem item;

  @override
  State<_RxItemRow> createState() => _RxItemRowState();
}

class _RxItemRowState extends State<_RxItemRow> {
  bool _detailExpanded = false;

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
                // İlaç adı + barkod
                Expanded(
                  child: Column(
                    spacing: 2.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.medicine?.name ?? '—', style: MedTextStyles.titleLg()),
                      if (item.medicine?.barcode != null) ...[
                        Text(item.medicine!.barcode!, style: MedTextStyles.monoMd(color: MedColors.text4)),
                      ],
                    ],
                  ),
                ),

                Row(
                  spacing: 6.0,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Saat chip
                    if (status != null) ...[
                      const SizedBox(height: MedSpacing.xs),
                      MedInfoChip(
                        info: status.label,
                        backgroundColor: status.backgroundColor,
                        foregroundColor: status.color,
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
                    child: _RxItemDetail(item: item),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _RxItemDetail extends StatelessWidget {
  const _RxItemDetail({required this.item});

  final PrescriptionItem item;

  List<_BlockData> _buildBlocks() {
    final blocks = <_BlockData>[];

    // Onay bloğu — her zaman göster (approvalUser veya createdUser)
    blocks.add(
      _BlockData(
        title: 'Onay',
        accentColor: MedColors.blue,
        fields: [
          _FieldData(label: 'Onaylayan', value: item.approvalUser?.fullName),
          _FieldData(label: 'Onay Tarihi', value: item.approvalDate.formattedDateTime),
          _FieldData(
            label: 'Miktar',
            value: '${item.dosePiece!.formatFractional} ${item.medicine?.operationUnit ?? ''}',
          ),
        ],
      ),
    );

    final status = item.status;
    if (status == null) return blocks;

    // Uygulama bloğu
    if (_hasApplicationBlock(status)) {
      blocks.add(
        _BlockData(
          title: 'Uygulama',
          accentColor: MedColors.green,
          fields: [
            _FieldData(label: 'Uygulayan', value: item.applicationUser?.fullName),
            _FieldData(label: 'Uygulama Tarihi', value: item.applicationDate.formattedDateTime),
            _FieldData(
              label: 'Miktar',
              value: item.dosePiece != null
                  ? '${item.dosePiece!.formatFractional} ${item.medicine?.operationUnit ?? ''}'
                  : null,
            ),
          ],
        ),
      );
    }

    // İade bloğu
    if (status == PrescriptionStatus.returned) {
      blocks.add(
        _BlockData(
          title: 'İade',
          accentColor: MedColors.blue,
          fields: [
            _FieldData(label: 'İade Eden', value: item.returnUser?.fullName),
            _FieldData(label: 'İade Tarihi', value: item.returnDate.formattedDateTime),
            _FieldData(
              label: 'İade Miktarı',
              value: item.returnQuantity != null
                  ? '${item.returnQuantity!.formatFractional} ${item.medicine?.operationUnit ?? ''}'
                  : null,
            ),
          ],
        ),
      );
    }

    // Fire bloğu
    if (status == PrescriptionStatus.wastaged) {
      blocks.add(
        _BlockData(
          title: 'Fire',
          accentColor: MedColors.amber,
          fields: [
            _FieldData(label: 'Fire Eden', value: item.wastageUser?.fullName),
            _FieldData(label: 'Fire Tarihi', value: item.wastageDate.formattedDateTime),
          ],
        ),
      );
    }

    // İmha bloğu
    if (status == PrescriptionStatus.destructed) {
      blocks.add(
        _BlockData(
          title: 'İmha',
          accentColor: MedColors.red,
          fields: [
            _FieldData(label: 'İmha Eden', value: item.destructionUser?.fullName),
            _FieldData(label: 'İmha Tarihi', value: item.destructionDate.formattedDateTime),
          ],
        ),
      );
    }

    // İptal bloğu
    if (status == PrescriptionStatus.cancelled || status == PrescriptionStatus.rejected) {
      blocks.add(
        _BlockData(
          title: status == PrescriptionStatus.cancelled ? 'İptal' : 'Red',
          accentColor: MedColors.red,
          fields: [
            _FieldData(
              label: status == PrescriptionStatus.cancelled ? 'İptal Eden' : 'Reddeden',
              value: item.cancelUser?.fullName ?? item.rejectUser?.fullName,
            ),
            _FieldData(label: 'Tarih', value: item.cancelDate?.formattedDateTime ?? item.rejectDate?.formattedDateTime),
            if (item.deleteDescription != null) _FieldData(label: 'Açıklama', value: item.deleteDescription),
          ],
        ),
      );
    }

    return blocks;
  }

  bool _hasApplicationBlock(PrescriptionStatus status) =>
      status == PrescriptionStatus.applied ||
      status == PrescriptionStatus.returned ||
      status == PrescriptionStatus.wastaged ||
      status == PrescriptionStatus.destructed;

  @override
  Widget build(BuildContext context) {
    final blocks = _buildBlocks();
    if (blocks.isEmpty) return const SizedBox.shrink();

    // Blokları max 2'li satırlara böl
    final rows = <List<_BlockData>>[];
    for (var i = 0; i < blocks.length; i += 2) {
      rows.add(blocks.sublist(i, (i + 2).clamp(0, blocks.length)));
    }

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border2, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int r = 0; r < rows.length; r++) ...[
            if (r > 0) Divider(height: 1, thickness: 2, color: MedColors.border2),
            IntrinsicHeight(
              child: Row(
                children: [
                  for (int b = 0; b < rows[r].length; b++) ...[
                    if (b > 0) VerticalDivider(width: 1, thickness: 1, color: MedColors.border2),
                    Expanded(child: _DetailBlock(data: rows[r][b])),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.data});

  final _BlockData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MedSpacing.xl2),
      child: Column(
        spacing: 8.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(data.title.toUpperCase(), style: MedTextStyles.titleMd(color: data.accentColor)),
          // Alanlar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(data.fields.length, (index) => _FieldRow(field: data.fields.elementAt(index))),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.field});

  final _FieldData field;

  @override
  Widget build(BuildContext context) {
    final isEmpty = field.value == null || field.value!.isEmpty;
    final displayValue = isEmpty ? '—' : field.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: MedTextStyles.monoMd(color: MedColors.text4)),
        const SizedBox(height: 1),
        Text(displayValue, style: MedTextStyles.monoMd()),
      ],
    );
  }
}

class _BlockData {
  const _BlockData({required this.title, required this.accentColor, required this.fields});
  final String title;
  final Color accentColor;
  final List<_FieldData> fields;
}

class _FieldData {
  const _FieldData({required this.label, required this.value});
  final String label;
  final String? value;
}
