// part of 'master_intake_execution_view.dart';

// class IntakeCellCard extends StatelessWidget {
//   const IntakeCellCard({
//     super.key,
//     required this.group,
//     required this.targets,
//     required this.onCountChanged,
//     this.stepLabel,
//     this.density = MedValueCardDensity.compact,
//   });

//   final IntakeCellGroup group;

//   /// job.targets — grup içindeki ref'leri (targetIndex, detailIndex) çözmek için.
//   final List<IntakeTarget> targets;

//   /// Grup birleşikse (aynı stockId birden fazla target'ta), value TÜM
//   /// ref'lere aynı anda yazılır — çağıran (onGroupCountChanged) bunu yönetir.
//   final void Function(double? value) onCountChanged;

//   final String? stepLabel;
//   final MedValueCardDensity density;

//   IntakeTarget get _representativeTarget => targets[group.refs.first.$1];
//   IntakeDetail get _representativeDetail {
//     final (ti, di) = group.refs.first;
//     return targets[ti].details[di];
//   }

//   double get _totalDose => group.refs.fold<double>(0, (sum, ref) => sum + targets[ref.$1].details[ref.$2].dosePiece);

//   bool get _needsCount => _representativeTarget.needsCount;

//   static double? _parseQty(String? raw) {
//     if (raw == null || raw.trim().isEmpty) return null;
//     return double.tryParse(raw.trim().replaceAll(',', '.'));
//   }

//   Future<void> _openNumpad(BuildContext context) async {
//     final result = await showNumpadView(context, initialValue: _representativeDetail.censusQuantity.formatFractional);
//     if (result != null) onCountChanged(_parseQty(result));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final target = _representativeTarget;
//     final unit = target.medicine?.operationUnitLocalized(context) ?? context.l10n.refillList_defaultUnitFallback;

//     return Container(
//       padding: MedSpacing.insetXl,
//       decoration: BoxDecoration(
//         color: MedColors.surface,
//         border: Border.all(color: MedColors.border),
//         borderRadius: MedRadius.mdAll,
//         boxShadow: MedShadows.sm,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         spacing: 10,
//         children: [_header(context, target, unit), if (_needsCount) _censusRow(context, unit)],
//       ),
//     );
//   }

//   Widget _header(BuildContext context, IntakeTarget target, String unit) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         if (stepLabel != null) ...[
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//             decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.smAll),
//             child: Text(stepLabel!, style: MedTextStyles.monoSm(color: MedColors.blue)),
//           ),
//           const SizedBox(width: 8),
//         ],
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 target.medicine?.name ?? '—',
//                 style: MedTextStyles.titleMd(color: MedColors.text),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               if (target.medicine?.barcode != null)
//                 Text(
//                   target.medicine!.barcode!,
//                   style: MedTextStyles.bodyMd(color: MedColors.text),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               // Birleşik grup: kaç farklı reçeteden toplandığını belirt —
//               // kullanıcı "neden bu miktar büyük" sorusuna cevap bulsun.
//               if (group.isMerged)
//                 Text(
//                   context.l10n.intake_hint_mergedFromMultiplePrescriptions(group.refs.length),
//                   style: MedTextStyles.bodySm(color: MedColors.text3),
//                 ),
//             ],
//           ),
//         ),
//         Text(
//           context.l10n.intake_label_takenAmount(_totalDose.formatFractional, unit),
//           style: MedTextStyles.monoMd(color: MedColors.blue),
//         ),
//       ],
//     );
//   }

//   Widget _censusRow(BuildContext context, String unit) {
//     final detail = _representativeDetail;
//     return MedValueCard(
//       density: density,
//       label: context.l10n.intake_label_countFieldLabel(unit),
//       value: detail.censusQuantity.formatFractional,
//       placeholder: detail.censusQuantity == null,
//       suffix: unit,
//       onTap: () => _openNumpad(context),
//     );
//   }
// }
