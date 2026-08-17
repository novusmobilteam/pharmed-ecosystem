// Master kabin işlem ekranlarının (dolum, sayım, iade, imha) ortak üst
// şerit: kuyruk ilerlemesi + "Dur" butonu.

import 'package:flutter/material.dart';
import 'package:pharmed_client/widgets/med_rectangle_button.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CabinExecutionTopStrip extends StatelessWidget {
  const CabinExecutionTopStrip({
    super.key,
    required this.progressLabel,
    required this.progress,
    required this.onStop,
    required this.stopLabel,
    required this.stopConfirmTitle,
    required this.stopConfirmMessage,
    required this.stopConfirmYesLabel,
    required this.cancelLabel,
  });

  /// "3 / 8 çekmece" gibi hazır, insan-okur ilerleme metni.
  final String progressLabel;

  /// 0..1 arası ilerleme oranı.
  final double progress;

  final Future<void> Function() onStop;

  final String stopLabel;
  final String stopConfirmTitle;
  final String stopConfirmMessage;
  final String stopConfirmYesLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 2, color: MedColors.text3)),
      ),
      child: Row(
        spacing: 32,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yürütme', style: MedTextStyles.monoMd(color: MedColors.blue)),
              Text('İlaç Dolum', style: MedTextStyles.titleLg()),
            ],
          ),
          SizedBox(
            width: 500,
            child: Column(
              spacing: 6.0,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kuyruk İlerlemesi', style: MedTextStyles.monoMd()),
                    Text(
                      progressLabel,
                      style: MedTextStyles.monoMd(color: MedColors.text2, weight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  width: 500,
                  child: MedProgressBar(
                    value: progress,
                    color: MedColors.blue,
                    height: 10,
                    backgroundColor: MedColors.border2,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          MedRectangleButton(
            label: stopLabel,
            height: 40,
            width: 150,
            backgroundColor: MedColors.red,
            foregroundColor: Colors.white,
            onTap: () => _confirmStop(context),
            suffixIcon: PhosphorIconsFill.stop,
          ),
          // MedButton(
          //   label: stopLabel,
          //   variant: MedButtonVariant.danger,
          //   size: MedButtonSize.sm,
          //   onPressed: () => _confirmStop(context),
          // ),
        ],
      ),
    );
  }

  void _confirmStop(BuildContext context) {
    MessageUtils.showConfirmDialog(
      context: context,
      action: ConfirmAction.custom,
      customTitle: stopConfirmTitle,
      customMessage: stopConfirmMessage,
      iconData: PhosphorIcons.warning(),
      color: MedColors.red,
      confirmButtonText: stopConfirmYesLabel,
      cancelButtonText: cancelLabel,
      onConfirm: onStop,
    );
  }
}
