import 'package:flutter/material.dart' hide Drawer;

class CabinDesignView extends StatelessWidget {
  const CabinDesignView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

// class CabinDesignView extends StatefulWidget {
//   const CabinDesignView({super.key});

//   @override
//   State<CabinDesignView> createState() => _CabinDesignViewState();
// }

// class _CabinDesignViewState extends State<CabinDesignView> {
//   CabinDesignNotifier? _notifier;

//   void _setupCallbacks(BuildContext context, CabinDesignNotifier notifier) {
//     // Scan Operation Callbacks
//     notifier.setCallbacks(
//       key: notifier.scanOp,
//       onLoading: () => showLoading(context, message: 'Kabin senkronize ediliyor.\nLütfen bekleyiniz..'),
//       onError: (msg) {
//         hideLoading(context);
//         MessageUtils.showErrorSnackbar(context, msg.toString());
//       },
//       onSuccess: (msg) {
//         hideLoading(context);
//         MessageUtils.showSuccessSnackbar(context, msg.toString());
//       },
//     );
//     // TODO : Kayıt etme işlemi için de aynı işlem yapılıp test edilecek.
//     // Ayrıca, tanımlı kabinin olmadığı senaryo servisler düzenlendikten sonra ele alınacak.
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (BuildContext context) => CabinDesignNotifier(
//         scanCabinUseCase: context.read(),
//         saveCabinDesignUseCase: context.read(),
//         cabinsUseCase: context.read(),
//         layoutUseCase: context.read(),
//       )..initCabinContext(),
//       child: Consumer<CabinDesignNotifier>(
//         builder: (context, notifier, _) {
//           if (_notifier != notifier) {
//             _notifier = notifier;
//             _setupCallbacks(context, notifier);
//           }

//           return CustomDialog(
//             title: 'Kabin Dizayn',
//             maxHeight: context.height,
//             width: context.width * 0.9,
//             actions: [
//               TextButton(onPressed: notifier.scanCabin, child: Text('Senkronize Et')),
//               TextButton(onPressed: () => showCabinRegistrationDialog(context), child: Text('Kabin Ekle')),
//             ],
//             child: _buildChild(notifier),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildChild(CabinDesignNotifier notifier) {
//     if (notifier.isFetching && notifier.cabins.isEmpty) {
//       return Center(child: CircularProgressIndicator.adaptive());
//     }

//     if (notifier.cabins.isEmpty) {
//       return Center(child: CommonEmptyStates.noCabin());
//     }

//     if (notifier.hasScanResults) {
//       return _scannedPreviewLayoutView(notifier);
//     } else {
//       return _existingLayoutView(notifier);
//     }
//   }

//   Widget _existingLayoutView(CabinDesignNotifier notifier) {
//     return CabinEditorView<dynamic>(
//       mode: CabinViewMode.viewOnly,
//       cabinId: notifier.selectedCabin?.id ?? 0,
//       layouts: notifier.displayLayout,
//       cabins: notifier.cabins,
//       selectedCabin: notifier.selectedCabin,
//       onCabinChanged: notifier.onCabinChanged,
//       cellData: null,
//       cellBuilder: (context, unit, data) {
//         return BaseUnitCell(workingStatus: unit.workingStatus, child: SizedBox());
//       },
//     );
//   }

//   Widget _scannedPreviewLayoutView(CabinDesignNotifier notifier) {
//     return Column(
//       spacing: 20,
//       children: [
//         Expanded(child: _existingLayoutView(notifier)),
//         if (notifier.hasScanResults)
//           Container(
//             padding: EdgeInsets.all(12.0),
//             decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0), color: context.colorScheme.primary),
//             child: Row(
//               children: [
//                 if (notifier.isSubmitting)
//                   CircularProgressIndicator.adaptive()
//                 else
//                   PharmedButton(
//                     onPressed: () => notifier.submit(),
//                     label: 'Tasarımı Kaydet',
//                     backgroundColor: context.colorScheme.onPrimary,
//                     foregroundColor: context.colorScheme.primary,
//                   ),
//                 TextButton(
//                   onPressed: () => notifier.clearScanForCurrentCabin(),
//                   style: TextButton.styleFrom(foregroundColor: context.colorScheme.onPrimary),
//                   child: const Text("Tarama Sonuçlarını Temizle"),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
// }

// void showCabinRegistrationDialog(BuildContext context) async {
//   final result = await showDialog<bool?>(
//     context: context,
//     builder: (context) {
//       return ChangeNotifierProvider(
//         create: (context) =>
//             CabinDesignFormNotifier(createCabinUseCase: context.read(), updateCabinUseCase: context.read()),
//         child: CabinDesignFormDialog(),
//       );
//     },
//   );

//   if (context.mounted && result == true) {
//     context.read<CabinDesignNotifier>().initCabinContext();
//   }
// }
