// [SWREQ-UI-RX-DETAIL-BLOCK-001]
// Sınıf: Class A
//
// RxGroupCard ve RxItemCard tarafından ortak kullanılan
// reçete kalem detay blok bileşenleri.

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class RxStatusDetailBlock extends StatelessWidget {
  const RxStatusDetailBlock({super.key, required this.item});

  final PrescriptionItem item;

  @override
  Widget build(BuildContext context) {
    final blocks = _buildBlocks(item);
    if (blocks.isEmpty) return const SizedBox.shrink();

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

List<_BlockData> _buildBlocks(PrescriptionItem item) {
  final blocks = <_BlockData>[];
  final status = item.status;

  // Onay bloğu — her zaman
  blocks.add(
    _BlockData(
      title: 'Onay',
      accentColor: MedColors.blue,
      fields: [
        _FieldData(label: 'Onaylayan', value: item.approvalUser?.fullName),
        _FieldData(label: 'Tarih', value: item.approvalDate.formattedDateTime),
        _FieldData(
          label: 'Miktar',
          value: item.dosePiece != null
              ? '${item.dosePiece!.formatFractional} ${item.medicine?.operationUnit ?? ''}'
              : null,
        ),
      ],
    ),
  );

  if (status == null) return blocks;

  // Uygulama bloğu
  if (_hasApplicationBlock(status)) {
    blocks.add(
      _BlockData(
        title: 'Uygulama',
        accentColor: MedColors.green,
        fields: [
          _FieldData(label: 'Uygulayan', value: item.applicationUser?.fullName),
          _FieldData(label: 'Tarih', value: item.applicationDate.formattedDateTime),
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
          _FieldData(label: 'Tarih', value: item.returnDate.formattedDateTime),
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
          _FieldData(label: 'Tarih', value: item.wastageDate.formattedDateTime),
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
          _FieldData(label: 'Tarih', value: item.destructionDate.formattedDateTime),
        ],
      ),
    );
  }

  // İptal / Red bloğu
  if (status == PrescriptionStatus.cancelled || status == PrescriptionStatus.rejected) {
    final isCancelled = status == PrescriptionStatus.cancelled;
    blocks.add(
      _BlockData(
        title: isCancelled ? 'İptal' : 'Red',
        accentColor: MedColors.red,
        fields: [
          _FieldData(
            label: isCancelled ? 'İptal Eden' : 'Reddeden',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.fields.map((f) => _FieldRow(field: f)).toList(),
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
    final displayValue = (field.value == null || field.value!.isEmpty) ? '—' : field.value!;
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
