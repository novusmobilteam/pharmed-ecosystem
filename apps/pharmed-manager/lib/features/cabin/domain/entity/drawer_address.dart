import 'package:pharmed_core/pharmed_core.dart';

import '../../../cabin_assignment/domain/entity/cabin_assignment.dart';
import 'drawer_cell.dart';

class DrawerAddress {
  final int row; // Satır (Yönetim Kartı Adresi)
  final int port; // Port No
  final int index; // Çekmece/Göz No (Drawer veya OrderNo)
  final bool isCubic; // Kübik mi?

  DrawerAddress({required this.row, required this.port, required this.index, this.isCubic = false}) {
    if (row < 0) throw ArgumentError("Satır adresi negatif olamaz.");
    if (port < 1 || port > 8) throw ArgumentError("Port 1-8 arasında olmalı.");
  }

  // Kübik Ana Kilidi için özel bir factory
  factory DrawerAddress.cubicMaster(int row) {
    return DrawerAddress(
      row: row,
      port: DeviceConstants.masterLockPort, // Sabit Port 1
      index: DeviceConstants.cubicMasterDrawerId, // Sabit ID 30
      isCubic: true,
    );
  }

  @override
  String toString() => "Row:$row, Port:$port, Index:$index";
}

DrawerAddress calculateAddressFromAssignment(CabinAssignment item, {double requestedQuantity = 0}) {
  final slot = item.drawerUnit?.drawerSlot;
  final config = slot?.drawerConfig;

  final rowStr = slot?.address ?? "0";
  final isKubik = config?.drawerType?.isKubik ?? false;
  final port = item.drawerUnit?.compartmentNo ?? 1;
  final stepMultiplier = config?.stepMultiplier ?? 1;

  int targetIndex;

  if (isKubik) {
    targetIndex = item.drawerUnit?.orderNo ?? 1;
  } else {
    // KISMİ AÇILMA MANTIĞI (Standart Çekmece)
    if (requestedQuantity > 0 && item.stocks != null && item.cabinDrawerDetail != null) {
      targetIndex = _calculatePartialStep(item, requestedQuantity);
    } else {
      // Adet belirtilmemişse veya stok verisi yoksa tam aç (eski mantık)
      final numberOfSteps = config?.numberOfSteps ?? 1;
      targetIndex = numberOfSteps;
    }

    // Donanımın anlayacağı gerçek adım sayısına çevir (step * multiplier)
    targetIndex = targetIndex * stepMultiplier;
    if (targetIndex > 16) targetIndex = 16;
  }

  return DrawerAddress(row: int.tryParse(rowStr) ?? 0, port: port, index: targetIndex, isCubic: isKubik);
}

int _calculatePartialStep(CabinAssignment item, double requestedQuantity) {
  double accumulatedStock = 0;
  int targetStep = 1;

  // 1. Gözleri stepNo'ya göre sıralıyoruz (1, 2, 3...)
  final sortedDetails = List<DrawerCell>.from(item.cabinDrawerDetail!)
    ..sort((a, b) => (a.stepNo ?? 0).compareTo(b.stepNo ?? 0));

  for (var detail in sortedDetails) {
    targetStep = detail.stepNo ?? targetStep;

    // 2. Bu göze ait stok miktarını buluyoruz
    final stockInThisCell = item.stocks!
        .where((s) => s.cabinDrawerDetailId == detail.id)
        .fold<double>(0, (sum, s) => sum + (s.quantity ?? 0));

    accumulatedStock += stockInThisCell;

    // 3. İstenen adete ulaştıysak döngüden çıkıyoruz
    if (accumulatedStock >= requestedQuantity) {
      break;
    }
  }

  return targetStep;
}
