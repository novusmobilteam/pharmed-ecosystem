import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/info_chip.dart';

class PrescriptionItemCard extends StatelessWidget {
  const PrescriptionItemCard({super.key, required this.item, required this.index, this.onDelete});

  final int index;
  final PrescriptionItem item;
  final Function(int index)? onDelete;

  @override
  Widget build(BuildContext context) {
    final timesText = (item.times ?? []).map((t) => t.formattedTime).join('  •  ');

    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      width: context.width,
      decoration: AppDimensions.cardDecoration(context),
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.medicine?.name ?? '-',
                    style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(item.medicine?.barcode ?? '-', style: context.textTheme.labelMedium),
                ],
              ),
              IconButton(
                onPressed: () => onDelete?.call(index),
                padding: EdgeInsets.zero,
                iconSize: 16.0,
                icon: Icon(PhosphorIcons.trashSimple(), color: Colors.red),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(timesText, style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(
            '${item.dosePiece.formatFractional} ${item.medicine?.operationUnit ?? 'Adet'}',
            style: context.textTheme.bodySmall?.copyWith(),
          ),
          SizedBox(height: 10),
          InfoChip(
            info: item.requestType?.label,
            backgroundColor: item.requestType == RequestType.emergency ? Colors.red : null,
          ),
          SizedBox(height: 5),
          Row(
            spacing: 5,
            children: [
              if (item.firstDoseEmergency ?? false) InfoChip(info: 'İlk Doz Acil', backgroundColor: Colors.red),
              if (item.askDoctor ?? false) InfoChip(info: 'Doktora Sor', backgroundColor: Colors.deepPurple),
              if (item.inCaseOfNecessity ?? false) InfoChip(info: 'Lüzum Halinde', backgroundColor: Colors.amber),
            ],
          ),
          if (item.description != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Divider(color: context.theme.dividerColor, height: 1),
                SizedBox(height: 10),
                Text(item.description ?? '-', style: context.textTheme.bodySmall?.copyWith()),
              ],
            ),
        ],
      ),
    );
  }
}
