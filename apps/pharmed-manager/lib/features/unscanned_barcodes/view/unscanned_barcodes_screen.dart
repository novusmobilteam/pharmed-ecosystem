// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:provider/provider.dart';

// import '../../../core/core.dart';

// import '../notifier/unscanned_barcodes_notifier.dart';

// part 'delete_description_view.dart';
// part 'deleted_barcodes_view.dart';
// part 'scanned_barcodes_view.dart';
// part 'scan_barcode_view.dart';

// /// Eczane okutulmayan karekod listesi ekranı.
// ///
// /// Bu ekran:
// /// - Okutulamayan karekodları tablo olarak listeler
// /// - Karekod tarama ve silme işlemlerini destekler
// /// - Okutulan ve silinen karekodları görüntüleme imkanı sağlar
// class UnscannedBarcodesScreen extends StatelessWidget {
//   const UnscannedBarcodesScreen({super.key, required this.menu});

//   final MenuItem menu;

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => UnscannedBarcodesNotifier(
//         deleteUnscannedBarcodeUseCase: context.read(),
//         getUnscannedBarcodesUseCase: context.read(),
//         scanBarcodeUseCase: context.read(),
//         toggleBarcodeWarningUseCase: context.read(),
//         getScannedBarcodesUseCase: context.read(),
//         getDeletedBarcodesUseCase: context.read(),
//       )..getUnscannedBarcodes(),
//       child: Consumer<UnscannedBarcodesNotifier>(
//         builder: (context, notifier, _) {
//           return MedResponsiveLayout(
//             mobile: const MedMobileLayout(),
//             tablet: const MedTabletLayout(),
//             desktop: MedDesktopLayout(
//               title: menu.name ?? 'Okutulmayan Karekodlar',
//               subtitle: menu.description,
//               actions: [
//                 IconButton(
//                   onPressed: () => showScannedBarcodes(context),
//                   tooltip: 'Okutulan Karekodlar',
//                   icon: Icon(PhosphorIcons.qrCode()),
//                 ),
//                 IconButton(
//                   onPressed: () => showDeletedBarcodes(context),
//                   tooltip: 'Silinen Karekodlar',
//                   icon: Icon(PhosphorIcons.trashSimple()),
//                 ),
//                 if (notifier.canOpenWarning)
//                   IconButton(
//                     onPressed: notifier.toggleWarning,
//                     tooltip: 'Uyarı Aç/Kapa',
//                     icon: Icon(PhosphorIcons.warning()),
//                   ),
//               ],
//               child: _TableView(notifier: notifier),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _TableView extends StatelessWidget {
//   const _TableView({required this.notifier});

//   final UnscannedBarcodesNotifier notifier;

//   @override
//   Widget build(BuildContext context) {
//     return MedTable<PrescriptionItem>(
//       data: notifier.dateFilteredItems,
//       isLoading: notifier.isFetching,
//       enableExcel: true,
//       enableSearch: true,
//       enableDateFilter: true,
//       onSearchChanged: notifier.search,
//       onDateRangeChanged: (range) {
//         notifier.setStartDate(range?.start);
//         notifier.setEndDate(range?.end);
//       },
//       selectionMode: TableSelectionMode.single,
//       onSingleSelectionChanged: (selectedItem) => notifier.selectedItem = selectedItem,
//       columnDefs: buildColumnDefs(),
//       cellBuilder: (item, colIndex, value) => buildCell(item, colIndex, value),
//       actions: [
//         TableActionItem(
//           icon: PhosphorIcons.qrCode(),
//           tooltip: 'Karekod Gir',
//           onPressed: (data) => showScanBarcodeView(context, data),
//         ),
//         TableActionItem.delete(onPressed: (data) => showDeleteDescriptionView(context, data)),
//       ],
//       emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noResults),
//     );
//   }
// }

// List<TableColumnDef> buildColumnDefs() => const [
//   TableColumnDef(title: 'Kullanıcı'), // colIndex: 0
//   TableColumnDef(title: 'Protokol'), // colIndex: 1
//   TableColumnDef(title: 'Hasta Adı'), // colIndex: 2
//   TableColumnDef(title: 'Tarih'), // colIndex: 3
//   TableColumnDef(title: 'Mal Kodu'), // colIndex: 4
//   TableColumnDef(title: 'Malzeme'), // colIndex: 5
//   TableColumnDef(title: 'Miktar', numeric: true, flex: 0.7), // colIndex: 6
//   TableColumnDef(title: 'Açıklama', flex: 1.2), // colIndex: 7
//   TableColumnDef(title: 'Gerekçesi', flex: 1.2), // colIndex: 8
// ];

// Widget? buildCell(PrescriptionItem item, int colIndex, dynamic _) {
//   return switch (colIndex) {
//     0 => Text(item.approvalUser?.fullName ?? '-'),
//     1 => Text(item.protocolNo?.toString() ?? '-'),
//     2 => Text(item.patientName ?? '-'),
//     3 => Text(item.applicationDate.formattedDate),
//     4 => Text(item.medicine?.barcode?.toString() ?? '-'),
//     5 => Text(item.medicine?.name ?? '-'),
//     6 => Text(item.returnQuantity.toCustomString()),
//     7 => Text(item.description ?? '-'),
//     8 => Text(item.deleteDescription ?? '-'),
//     _ => null,
//   };
// }
