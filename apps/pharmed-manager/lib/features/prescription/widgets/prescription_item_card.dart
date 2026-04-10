import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/core.dart';

class PrescriptionItemCard extends StatelessWidget {
  const PrescriptionItemCard({super.key, required this.item, required this.index, this.onDelete});

  final int index;
  final PrescriptionItem item;
  final Function(int index)? onDelete;

  @override
  Widget build(BuildContext context) {
    final times = item.times ?? [];

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İndeks rozeti
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontFamily: MedFonts.mono,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: MedColors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        item.medicine?.name ?? '-',
                        style: TextStyle(
                          fontFamily: MedFonts.sans,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: MedColors.text,
                        ),
                      ),
                      if (item.medicine?.barcode != null)
                        Text(
                          item.medicine!.barcode!,
                          style: TextStyle(fontFamily: MedFonts.mono, fontSize: 10, color: MedColors.text3),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => onDelete?.call(index),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(PhosphorIcons.trashSimple(), size: 14, color: MedColors.red.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 0.5, color: MedColors.border2),

          // ── Meta
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                // Doz + istek tipi
                Row(
                  spacing: 6,
                  children: [
                    _MetaChip(
                      label: '${item.dosePiece.formatFractional} ${item.medicine?.operationUnit ?? 'Adet'}',
                      color: MedColors.blue,
                      bg: MedColors.blueLight,
                    ),
                    _requestTypeChip(item.requestType),
                  ],
                ),

                // Saatler
                if (times.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: times.map((t) => _TimeChip(label: t.formattedTime)).toList(),
                  ),

                // Ek bayraklar
                if (_hasFlags)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (item.firstDoseEmergency ?? false)
                        _MetaChip(label: 'İlk Doz Acil', color: MedColors.red, bg: MedColors.redLight),
                      if (item.askDoctor ?? false)
                        _MetaChip(label: 'Doktora Sor', color: const Color(0xFF6D28D9), bg: const Color(0xFFF5F3FF)),
                      if (item.inCaseOfNecessity ?? false)
                        _MetaChip(label: 'Lüzum Halinde', color: MedColors.amber, bg: MedColors.amberLight),
                    ],
                  ),

                // Açıklama
                if (item.description?.isNotEmpty == true)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MedColors.surface2,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: MedColors.border2),
                    ),
                    child: Text(
                      item.description!,
                      style: TextStyle(fontFamily: MedFonts.sans, fontSize: 11, color: MedColors.text2, height: 1.4),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasFlags =>
      (item.firstDoseEmergency ?? false) || (item.askDoctor ?? false) || (item.inCaseOfNecessity ?? false);

  Widget _requestTypeChip(RequestType? type) {
    final isEmergency = type == RequestType.emergency;
    return _MetaChip(
      label: type?.label ?? '-',
      color: isEmergency ? MedColors.red : MedColors.green,
      bg: isEmergency ? MedColors.redLight : MedColors.greenLight,
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color, required this.bg});

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(fontFamily: MedFonts.mono, fontSize: 10, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: MedColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(fontFamily: MedFonts.mono, fontSize: 10, color: MedColors.text3),
      ),
    );
  }
}
