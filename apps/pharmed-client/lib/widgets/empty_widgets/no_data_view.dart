import 'package:flutter/widgets.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class NoDataView extends StatelessWidget {
  const NoDataView({super.key, required this.title, required this.subtitle, required this.iconData});

  final String title;
  final String subtitle;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // İkon
          Row(
            spacing: 6.0,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: MedColors.surface2,
                  borderRadius: MedRadius.midAll,
                  border: Border.all(color: MedColors.border2),
                ),
              ),
              Container(
                width: 60,
                height: 100,
                decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.midAll),
                child: Center(child: Icon(iconData, color: MedColors.blue)),
              ),
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: MedColors.surface2,
                  borderRadius: MedRadius.midAll,
                  border: Border.all(color: MedColors.border2),
                ),
              ),
            ],
          ),
          // Title
          SizedBox(height: 12.0),
          Text(title, style: MedTextStyles.titleMd()),
          // Subtitle
          SizedBox(height: 6.0),
          Text(subtitle, style: MedTextStyles.bodySm()),
          // // Instructions
          // SizedBox(height: 12.0),
          // Column(
          //   spacing: 8.0,
          //   children: [
          //     Row(
          //       spacing: 8.0,
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         MedChip(label: context.l10n.myPatients_chip_step1, size: MedChipSize.lg),
          //         MedChip(label: context.l10n.myPatients_chip_step2, size: MedChipSize.lg),
          //       ],
          //     ),
          //     MedChip(label: context.l10n.myPatients_chip_step3, size: MedChipSize.lg),
          //   ],
          // ),
        ],
      ),
    );
  }
}
