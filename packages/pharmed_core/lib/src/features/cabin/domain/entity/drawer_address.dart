import 'package:pharmed_core/pharmed_core.dart';

class DrawerAddress {
  final int row; // Satır (Yönetim Kartı Adresi)
  final int port; // Port No
  final int index; // Çekmece/Göz No (Drawer veya OrderNo)
  final bool isCubic; // Kübik mi?

  DrawerAddress({required this.row, required this.port, required this.index, this.isCubic = false}) {
    if (row < 0) throw ArgumentError("Satır adresi negatif olamaz.");
    if (port < 1 || port > 8) throw ArgumentError("Port 1-8 arasında olmalı.");
  }

  factory DrawerAddress.cubicMaster(int row) {
    return DrawerAddress(
      row: row,
      port: DeviceConstants.masterLockPort,
      index: DeviceConstants.cubicMasterDrawerId,
      isCubic: true,
    );
  }

  @override
  String toString() => "Row:$row, Port:$port, Index:$index";
}

/// [explicitTargetStep]: hedef göz ZATEN ÇÖZÜLMÜŞ akışlar için (alım/iade —
/// CheckIntake/CheckRefund planı hangi stoktan alınacağını/konacağını zaten
/// belirledi). Verildiğinde [_calculatePartialStep]'in kümülatif stok
/// toplama mantığına HİÇ girilmez — bu iki farklı "hedef göz kararı"
/// mekanizmasının (FIFO burada vs FIFO check'te) çakışmasını/tekrar
/// hesaplanmasını önlemek için kasıtlı bir kısayoldur.
///
/// [requestedQuantity]: hedef göz henüz çözülmemiş akışlar için (dolumda
/// hiç kullanılmaz — sabit 0, tam açılış; orderless/free alımda ileride
/// kullanılacak — kullanıcı miktar girer, sistem kümülatif stoktan göz
/// hesaplar).
DrawerAddress calculateAddressFromAssignment(
  MedicineAssignment item, {
  double requestedQuantity = 0,
  int? explicitTargetStep,
}) {
  final slot = item.drawerUnit?.drawerSlot;
  final config = slot?.drawerConfig;

  final rowStr = slot?.address ?? "0";
  final isKubik = config?.drawerType?.isKubik ?? false;
  final rawPort = item.drawerUnit?.compartmentNo ?? 1;
  final port = isKubik
      ? rawPort // kübikte port sabit 1-4 aralığında, ters çevirme henüz gözlemlenmedi/uygulanmıyor
      : _resolvePhysicalPort(
          rawPort: rawPort,
          totalPorts: config?.drawerType?.compartmentCount,
          // TODO(GEÇİCİ - TEST): backend'de isPortReversed alanı/kurulum
          // ekranı toggle'ı henüz yok. Şu an TÜM birim doz çekmeceleri için
          // sabit true zorlanıyor - kurulum ekranına toggle eklenene veya
          // backend'den gerçek değer okunana kadar SADECE test ortamında
          // kullanılmalı, bu haliyle production'a alınmamalı (diğer normal
          // kablolu kabinleri de yanlışlıkla ters çevirir).
          isReversed: true, // slot?.isPortReversed ?? false,
        );
  final stepMultiplier = config?.stepMultiplier ?? 1;

  int targetIndex;

  if (isKubik) {
    targetIndex = item.drawerUnit?.orderNo ?? 1;
  } else if (explicitTargetStep != null) {
    // Hedef göz zaten çözülmüş (check/FIFO sonucu) — kümülatif hesaba hiç
    // girilmez, doğrudan bu adıma gidilir.
    targetIndex = explicitTargetStep;
  } else if (requestedQuantity > 0 && item.stocks != null && item.cabinDrawerDetail != null) {
    // KISMİ AÇILMA MANTIĞI (Standart Çekmece) — hedef henüz bilinmiyor,
    // kümülatif stoktan hesapla.
    targetIndex = _calculatePartialStep(item, requestedQuantity);
  } else {
    // Adet belirtilmemişse veya stok verisi yoksa tam aç (eski mantık)
    final numberOfSteps = config?.numberOfSteps ?? 1;
    targetIndex = numberOfSteps;
  }

  if (!isKubik) {
    // Donanımın anlayacağı gerçek adım sayısına çevir (step * multiplier)
    targetIndex = targetIndex * stepMultiplier;
    if (targetIndex > 16) targetIndex = 16;
  }

  return DrawerAddress(row: int.tryParse(rowStr) ?? 0, port: port, index: targetIndex, isCubic: isKubik);
}

/// [rawPort]'u fiziksel kablolamaya göre gerçek donanım port numarasına
/// çevirir. [isReversed] false/[totalPorts] null-veya-0 ise değişiklik
/// yapılmaz (aynen döner).
///
/// Formül: `totalPorts + 1 - rawPort` — basit ayna simetrisi. Donanım
/// testiyle doğrulandı (5 gözlü çekmecede port=2↔4 karşılıklı test edildi,
/// bkz. hardware-services skill).
int _resolvePhysicalPort({required int rawPort, int? totalPorts, required bool isReversed}) {
  if (!isReversed || totalPorts == null || totalPorts <= 0) return rawPort;
  return totalPorts + 1 - rawPort;
}

int _calculatePartialStep(MedicineAssignment item, double requestedQuantity) {
  double accumulatedStock = 0;
  int targetStep = 1;

  final sortedDetails = List<DrawerCell>.from(item.cabinDrawerDetail!)
    ..sort((a, b) => (a.stepNo ?? 0).compareTo(b.stepNo ?? 0));

  for (var detail in sortedDetails) {
    targetStep = detail.stepNo ?? targetStep;

    final stockInThisCell = item.stocks!
        .where((s) => s.cabinDrawerDetailId == detail.id)
        .fold<double>(0, (sum, s) => sum + (s.quantity ?? 0));

    accumulatedStock += stockInThisCell;

    if (accumulatedStock >= requestedQuantity) {
      break;
    }
  }

  return targetStep;
}
