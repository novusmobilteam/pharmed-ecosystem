// import 'package:flutter/material.dart';
// import 'package:pharmed_core/pharmed_core.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';
// import 'package:pharmed_utils/pharmed_utils.dart';

// import '../../../../core/hardware/hardware.dart';
// import '../notifier/master_intake_execution_notifier.dart';

// class IntakeActiveMedicineCard extends StatelessWidget {
//   const IntakeActiveMedicineCard({super.key, required this.notifier, required this.hospitalization});

//   final MasterIntakeExecutionNotifier notifier;
//   final Hospitalization hospitalization;

//   static double? _parseQty(String? raw) {
//     if (raw == null || raw.trim().isEmpty) return null;
//     return double.tryParse(raw.trim().replaceAll(',', '.'));
//   }

//   Future<void> _openNumpad(BuildContext context, int detailIndex, double? currentValue) async {
//     final result = await showNumpadView(context, initialValue: currentValue.formatFractional);
//     if (result != null) notifier.updateCurrentTargetCount(detailIndex, _parseQty(result));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final target = notifier.currentTarget;
//     if (target == null) return const SizedBox.shrink();
//     final unit = target.medicine?.operationUnitLocalized(context) ?? context.l10n.refillList_defaultUnitFallback;

//     return Container(
//       padding: MedSpacing.insetXl,
//       decoration: MedDecoration.panelDecoration,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(target.medicine?.name ?? '', style: MedTextStyles.titleLg()),
//           Text(target.medicine?.barcode ?? '', style: MedTextStyles.monoMd()),
//           if (target.medicine?.collectNote != null)
//             Text(
//               '${context.l10n.medicine_fieldCollectNote}: ${target.medicine?.collectNote}',
//               style: MedTextStyles.bodyMd(weight: FontWeight.bold),
//             ),
//           SizedBox(height: 12.0),
//           for (var i = 0; i < target.details.length; i++)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: MedValueCard(
//                 density: MedValueCardDensity.comfortable,
//                 label: context.l10n.intake_label_countFieldLabel(unit),
//                 value: target.details[i].censusQuantity.formatFractional,
//                 placeholder: target.details[i].censusQuantity == null,
//                 suffix: unit,
//                 onTap: () => _openNumpad(context, i, target.details[i].censusQuantity),
//               ),
//             ),
//           Spacer(),
//           Builder(
//             builder: (context) {
//               final target = notifier.currentTarget;
//               final job = notifier.currentJob;
//               final isLastTarget = job == null || notifier.currentTargetIndex >= job.targets.length - 1;

//               // Fiziksel çekmece/lid TAM AÇIK değilse (Opening/WaitingForPull/
//               // WaitingForClose/Closed-ara-an gibi geçiş durumlarındaysa) buton
//               // KESİNLİKLE tıklanamaz — bu, "kapanma bekleniyor" penceresinde ikinci
//               // bir complete isteğinin gitmesini engelleyen tek koruma.
//               final isDrawerReady = notifier.drawerStage is MasterDrawerOpened;
//               final canConfirm = isDrawerReady && (target?.isValid ?? false) && !notifier.isSaving;

//               return MedButton(
//                 label: isLastTarget ? context.l10n.intake_action_complete : context.l10n.refill_action_nextCell,
//                 fullWidth: true,
//                 isLoading: notifier.isSaving,
//                 onPressed: canConfirm ? notifier.confirmCurrent : null,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
