// part of 'inconsistency_screen.dart';

// class InconsistencySummaryView extends StatelessWidget {
//   const InconsistencySummaryView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       spacing: AppDimensions.registrationDialogSpacing,
//       children: [
//         Row(
//           spacing: AppDimensions.registrationDialogSpacing,
//           children: [
//             _MaterialField(),
//             _DateField(),
//             _UserField(),
//           ],
//         ),
//         Row(
//           spacing: AppDimensions.registrationDialogSpacing,
//           children: [
//             _RequiredQuantityField(),
//             _CountedQuantityField(),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _MaterialField extends StatelessWidget {
//   const _MaterialField();

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<InconsistencyDetailViewModel>(
//       builder: (context, vm, _) {
//         return Expanded(
//           child: TextInputField(
//             readOnly: true,
//             label: 'Malzeme',
//             initialValue: vm.detail?.summary?.material?.name,
//             onChanged: (_) {},
//           ),
//         );
//       },
//     );
//   }
// }

// class _DateField extends StatelessWidget {
//   const _DateField();

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<InconsistencyDetailViewModel>(
//       builder: (context, vm, _) {
//         return Expanded(
//           child: TextInputField(
//             readOnly: true,
//             label: 'Tarih',
//             initialValue: vm.detail?.summary?.date?.formattedDate,
//             onChanged: (_) {},
//           ),
//         );
//       },
//     );
//   }
// }

// class _UserField extends StatelessWidget {
//   const _UserField();

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<InconsistencyDetailViewModel>(
//       builder: (context, vm, _) {
//         return Expanded(
//           child: TextInputField(
//             readOnly: true,
//             initialValue: vm.detail?.summary?.user?.fullName,
//             label: 'Kullanıcı',
//             onChanged: (_) {},
//           ),
//         );
//       },
//     );
//   }
// }

// class _RequiredQuantityField extends StatelessWidget {
//   const _RequiredQuantityField();

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<InconsistencyDetailViewModel>(
//       builder: (context, vm, _) {
//         return Expanded(
//           child: TextInputField(
//             readOnly: true,
//             initialValue: vm.detail?.summary?.requiredQuantity?.toInt().toCustomString(),
//             label: 'Olması Gereken Miktar',
//             onChanged: (_) {},
//           ),
//         );
//       },
//     );
//   }
// }

// class _CountedQuantityField extends StatelessWidget {
//   const _CountedQuantityField();

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<InconsistencyDetailViewModel>(
//       builder: (context, vm, _) {
//         return Expanded(
//           child: TextInputField(
//             readOnly: true,
//             initialValue: vm.detail?.summary?.countedQuantity?.toInt().toCustomString(),
//             label: 'Sayım Miktarı',
//             onChanged: (_) {},
//           ),
//         );
//       },
//     );
//   }
// }
