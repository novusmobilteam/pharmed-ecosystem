import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';

import '../view_model/unscanned_barcodes_viewmodel.dart';

class UnscannedBarcodesScreen extends StatelessWidget {
  const UnscannedBarcodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UnscannedBarcodesViewModel(prescriptionRepository: context.read())..fetch(),
      child: Consumer<UnscannedBarcodesViewModel>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: DesktopLayout(
              title: 'Okutulmayan Karekodlar',
              showAddButton: false,
              child: UnifiedTableView<PrescriptionItem>(
                data: notifier.items,
                isLoading: notifier.isFetching,
                columnDefs: _buildColumnDefs(),
                cellBuilder: _buildCell,
              ),
            ),
          );
        },
      ),
    );
  }

  List<TableColumnDef> _buildColumnDefs() => const [
    TableColumnDef(title: 'Hasta', flex: 1.5), // colIndex: 0
    TableColumnDef(title: 'Barkod'), // colIndex: 1
    TableColumnDef(title: 'Malzeme', flex: 1.5), // colIndex: 2
    TableColumnDef(title: 'Tarih'), // colIndex: 3
    TableColumnDef(title: 'Miktar', numeric: true, flex: 0.7), // colIndex: 4
    TableColumnDef(title: 'Uygulayan'), // colIndex: 5
  ];

  Widget? _buildCell(PrescriptionItem item, int colIndex, dynamic _) {
    return switch (colIndex) {
      0 => Text(item.prescription?.hospitalization?.patient?.fullName ?? '-'),
      1 => Text(item.barcode.toCustomString()),
      2 => Text(item.medicine?.name ?? '-'),
      3 => Text(item.applicationDate?.formattedDate ?? '-'),
      4 => Text(item.dosePiece.toCustomString()),
      5 => Text(item.applicationUser?.fullName ?? '-'),
      _ => null,
    };
  }
}
