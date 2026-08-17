// part of 'mobile_census_panel.dart';

// class ReportExtraStockDialog extends StatefulWidget {
//   const ReportExtraStockDialog({super.key});

//   static Future<({Medicine medicine, double quantity})?> show(
//     BuildContext context, {
//     required GetMedicinesUseCase getMedicinesUseCase,
//   }) {
//     return showDialog<({Medicine medicine, double quantity})>(
//       context: context,
//       builder: (_) => ReportExtraStockDialog(),
//     );
//   }

//   @override
//   State<ReportExtraStockDialog> createState() => _ReportExtraStockDialogState();
// }

// class _ReportExtraStockDialogState extends State<ReportExtraStockDialog> {
//   Medicine? _selected;
//   double _quantity = 1;
//   bool get _canSubmit => _selected != null && _quantity > 0;

//   @override
//   Widget build(BuildContext context) {
//     return MedDialog(
//       width: 350,
//       title: context.l10n.census_extra_stock_dialog_title,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           MedSelectionField<Medicine>(
//             label: context.l10n.assignment_drugSectionLabel,
//             dataSource: (skip, take, search) =>
//                 context.read<GetMedicinesUseCase>().call(PagedQueryParams(skip: skip, take: take, searchQuery: search)),
//             labelBuilder: (m) => m.name ?? '—',
//             onSelected: (m) => setState(() => _selected = m),
//           ),
//           const SizedBox(height: MedSpacing.lg),
//           MedDoseStepper(
//             value: _quantity,
//             min: 1,
//             max: 999,
//             step: 1,
//             onChanged: (v) => setState(() => _quantity = v),
//             unit: context.l10n.census_extra_stock_quantity_label,
//           ),
//           const SizedBox(height: 20),
//           Row(
//             spacing: 6.0,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               MedButton(
//                 label: context.l10n.common_cancelButton,
//                 variant: MedButtonVariant.secondary,
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//               MedButton(
//                 label: context.l10n.common_action_add,
//                 onPressed: _canSubmit
//                     ? () => Navigator.of(context).pop((medicine: _selected!, quantity: _quantity))
//                     : null,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
