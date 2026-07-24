// Master kabin işlem ekranlarının (dolum, sayım, iade, imha) ortak üst
// şerit: kuyruk ilerlemesi + "Dur" butonu.

import 'package:flutter/material.dart';
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
    return Row(
      spacing: 16,
      children: [
        Text(progressLabel, style: MedTextStyles.bodySm(color: MedColors.text2)),
        Expanded(
          child: MedProgressBar(value: progress, color: MedColors.blue, height: 10, backgroundColor: MedColors.border2),
        ),
        MedButton(
          label: stopLabel,
          variant: MedButtonVariant.danger,
          size: MedButtonSize.sm,
          onPressed: () => _confirmStop(context),
        ),
      ],
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
