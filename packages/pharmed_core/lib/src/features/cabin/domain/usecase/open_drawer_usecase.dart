// [SWREQ-CORE-CABIN-UC-008]
// Sınıf: Class B

class OpenDrawerUseCase {
  final ICabinOperationService _service;

  OpenDrawerUseCase(this._service);

  Future<void> call({
    required CabinAssignment item,
    required Function(DrawerStage stage, String message) onUpdate,
    required Function(ManagementCard manager, DrawerAddress address) onReadyToMonitor,
    // Alım yapılırken girilecek, çekmeceden kaç adet ilaç alınacağı bilgisi.
    double requestedQuantity = 0.0,
    bool openCubicLid = true,
  }) async {
    try {
      final isSerum = item.drawerUnit?.drawerSlot?.drawerConfig?.isSerum ?? false;
      final address = calculateAddressFromAssignment(item, requestedQuantity: requestedQuantity);
      final portName = item.cabin?.comPort?.name;

      onUpdate(DrawerStage.connecting, "Cihaz hazırlanıyor...");

      // 1. Yönetim Kartı Bağlantısı
      final manager = await _service.getOrScanManager(targetPort: portName);
      if (manager == null) throw Exception("Yönetim kartı bulunamadı.");

      // 2. İzleme Başlatma Sinyali (Notifier bu noktada stream'i bağlar)
      final monitorAddress = (address.isCubic && !isSerum) ? DrawerAddress.cubicMaster(address.row) : address;
      onReadyToMonitor(manager, monitorAddress);

      // 3. Fiziksel Kilit Açma Akışları
      if (isSerum) {
        onUpdate(DrawerStage.unlockingMaster, "Serum kabini açılıyor...");
        await _service.unlockSerum(manager: manager, row: address.row);
      } else if (address.isCubic) {
        onUpdate(DrawerStage.unlockingMaster, "Ana kilit açılıyor...");
        await _service.unlockDrawer(
          manager: manager,
          row: monitorAddress.row,
          port: monitorAddress.port,
          drawer: monitorAddress.index,
        );
      } else {
        onUpdate(DrawerStage.unlockingMaster, "Çekmece kilidi açılıyor...");
        await _service.unlockDrawer(manager: manager, row: address.row, port: address.port, drawer: address.index);
      }

      onUpdate(DrawerStage.waitingForPull, "Kilit açıldı. Lütfen çekin.");
    } catch (_) {
      rethrow;
    }
  }
}
