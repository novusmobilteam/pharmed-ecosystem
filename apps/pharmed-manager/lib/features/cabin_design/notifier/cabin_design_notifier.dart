import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../cabin/domain/entity/drawer_group.dart';
import '../../cabin/domain/usecase/get_cabins_usecase.dart';
import '../../cabin/domain/usecase/get_cabin_layout_usecase.dart';
import '../../cabin/domain/usecase/save_cabin_design_usecase.dart';
import '../../cabin/domain/usecase/scan_cabin_usecase.dart';
import '../../cabin/shared/widgets/cabin_editor/cabin_editor_mixin.dart';

class CabinDesignNotifier extends ChangeNotifier with ApiRequestMixin, CabinEditorMixin {
  @override
  final GetCabinsUseCase cabinsUseCase;
  @override
  final GetCabinLayoutUseCase layoutUseCase;

  final ScanCabinUseCase _scanCabinUseCase;
  final SaveCabinDesignUseCase _saveCabinDesignUseCase;

  CabinDesignNotifier({
    required this.cabinsUseCase,
    required this.layoutUseCase,
    required ScanCabinUseCase scanCabinUseCase,
    required SaveCabinDesignUseCase saveCabinDesignUseCase,
  }) : _scanCabinUseCase = scanCabinUseCase,
       _saveCabinDesignUseCase = saveCabinDesignUseCase;

  OperationKey scanOp = OperationKey.custom('scan');
  OperationKey submitOp = OperationKey.submit();

  final Map<int, List<DrawerGroup>> _scannedLayoutsMap = {};

  // UI'da gösterilecek liste: Map'te o kabine ait data varsa onu, yoksa DB'dekini döner.
  List<DrawerGroup> get displayLayout {
    if (selectedCabin == null) return [];
    final scanned = _scannedLayoutsMap[selectedCabin!.id];
    return (scanned != null && scanned.isNotEmpty) ? scanned : layout;
  }

  // Mevcut seçili kabin için tarama sonucu var mı?
  bool get hasScanResults => selectedCabin != null && (_scannedLayoutsMap[selectedCabin!.id]?.isNotEmpty ?? false);

  // Loader Durumları
  bool get isScanning => isLoading(scanOp);
  bool get isSubmitting => isLoading(submitOp);

  /// Sayfa açılışında veya kabin değiştiğinde çalışır
  Future<void> scanCabin() async {
    if (selectedCabin == null) return;

    await execute<List<DrawerGroup>>(
      scanOp,
      operation: () => _scanCabinUseCase.call(
        portName: selectedCabin?.comPort?.name,
        cabinType: selectedCabin?.type ?? CabinType.master,
      ),
      onData: (data) {
        _scannedLayoutsMap[selectedCabin!.id!] = data;
        notifyListeners();
      },
      loadingMessage: 'Donanım taranıyor...',
    );
  }

  /// Seçili kabine ait mevcut tasarımı çeker
  Future<void> submit() async {
    final currentScanGroups = _scannedLayoutsMap[selectedCabin?.id];
    if (currentScanGroups == null || currentScanGroups.isEmpty || selectedCabin == null) return;

    final scanResults = currentScanGroups.map((g) => g.slot).toList();

    await executeVoid(
      submitOp,
      operation: () => _saveCabinDesignUseCase.call(
        cabinId: selectedCabin!.id!,
        scanResults: scanResults,
        isUpdate: layout.isNotEmpty,
      ),
      successMessage: 'Kabin tasarımı başarıyla güncellendi.',
      onSuccess: () {
        _scannedLayoutsMap.remove(selectedCabin!.id);
        refreshLayout(); // mixin'deki layout'u tazele
      },
    );
  }

  void clearScanForCurrentCabin() {
    if (selectedCabin != null) {
      _scannedLayoutsMap.remove(selectedCabin!.id);
      notifyListeners();
    }
  }
}
