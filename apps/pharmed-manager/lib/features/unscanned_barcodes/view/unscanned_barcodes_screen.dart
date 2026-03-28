import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import '../../prescription/domain/entity/prescription_item.dart';
import '../../prescription/domain/repository/i_prescription_repository.dart';
import '../view_model/unscanned_barcodes_viewmodel.dart';

part 'delete_description_view.dart';
part 'deleted_barcodes_view.dart';
part 'readed_barcodes_view.dart';
part 'scan_barcode_view.dart';
part 'table_view.dart';

/// Eczane okutulmayan karekod listesi ekranı.
///
/// Bu ekran:
/// - Okutulamayan karekodları tablo olarak listeler
/// - Karekod tarama ve silme işlemlerini destekler
/// - Okutulan ve silinen karekodları görüntüleme imkanı sağlar
class ManagerUnscannedBarcodesScreen extends StatefulWidget {
  const ManagerUnscannedBarcodesScreen({super.key});

  @override
  State<ManagerUnscannedBarcodesScreen> createState() => _UnscannedBarcodesScreenState();
}

class _UnscannedBarcodesScreenState extends State<ManagerUnscannedBarcodesScreen> {
  UnscannedBarcodesViewModel? _viewModel;

  void _setupCallbacks(BuildContext context, UnscannedBarcodesViewModel vm) {
    // Toggle Callback
    vm.setCallbacks(
      key: UnscannedBarcodesViewModel.toggleWarningOperation,
      onLoading: () => showLoading(context),
      onError: (message) {
        hideLoading(context);
        MessageUtils.showErrorDialog(context, message ?? 'Bir hata oluştu');
      },
      onSuccess: (message) {
        hideLoading(context);
        MessageUtils.showSuccessSnackbar(context, message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UnscannedBarcodesViewModel(
        prescriptionRepository: context.read(),
      )..fetchBarcodes(),
      child: Consumer<UnscannedBarcodesViewModel>(
        builder: (context, vm, _) {
          if (_viewModel != vm) {
            _viewModel = vm;
            _setupCallbacks(context, vm);
          }

          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: _buildDesktopLayout(context, vm),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, UnscannedBarcodesViewModel vm) {
    return DesktopLayout(
      title: 'Okutulmayan Karekod Listesi',
      showAddButton: false,
      actions: [
        IconButton(
          onPressed: () => showReadedBarcodes(context),
          tooltip: 'Okutulan Karekodlar',
          icon: Icon(PhosphorIcons.qrCode()),
        ),
        IconButton(
          onPressed: () => showDeletedBarcodes(context),
          tooltip: 'Silinen Karekodlar',
          icon: Icon(PhosphorIcons.trashSimple()),
        ),
        if (vm.canOpenWarning)
          IconButton(
            onPressed: vm.toggleWarning,
            tooltip: 'Uyarı Aç/Kapa',
            icon: Icon(PhosphorIcons.warning()),
          ),
      ],
      child: _buildContent(context, vm),
    );
  }

  /// Ekran içeriğini oluşturur.
  Widget _buildContent(BuildContext context, UnscannedBarcodesViewModel vm) {
    // Yükleniyor ve liste boşsa loading göster
    if (vm.isFetchingBarcodes && vm.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    // Liste boşsa empty state göster
    if (vm.isEmpty) {
      return CommonEmptyStates.generic(
        icon: Icons.qr_code_scanner,
        message: 'Okutulmayan karekod bulunmuyor',
        subMessage: 'Tüm karekodlar taranmış.',
      );
    }

    return _TableView(vm: vm);
  }
}

List<TableColumnDef> buildColumnDefs() => const [
      TableColumnDef(title: 'Kullanıcı'), // colIndex: 0
      TableColumnDef(title: 'Protokol'), // colIndex: 1
      TableColumnDef(title: 'Hasta Adı'), // colIndex: 2
      TableColumnDef(title: 'Tarih'), // colIndex: 3
      TableColumnDef(title: 'Mal Kodu'), // colIndex: 4
      TableColumnDef(title: 'Malzeme'), // colIndex: 5
      TableColumnDef(title: 'Miktar', numeric: true, flex: 0.7), // colIndex: 6
      TableColumnDef(title: 'Açıklama', flex: 1.2), // colIndex: 7
      TableColumnDef(title: 'Gerekçesi', flex: 1.2), // colIndex: 8
    ];

Widget? buildCell(PrescriptionItem item, int colIndex, dynamic _) {
  return switch (colIndex) {
    0 => Text(item.approvalUser?.fullName ?? '-'),
    1 => Text(item.protocolNo?.toString() ?? '-'),
    2 => Text(item.patientName ?? '-'),
    3 => Text(item.applicationDate.formattedDate),
    4 => Text(item.medicine?.barcode?.toString() ?? '-'),
    5 => Text(item.medicine?.name ?? '-'),
    6 => Text(item.returnQuantity.toCustomString()),
    7 => Text(item.description ?? '-'),
    8 => Text(item.deleteDescription ?? '-'),
    _ => null,
  };
}
