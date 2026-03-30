// [SWREQ-CORE-CABIN-UC-007]
// Sınıf: Class B

class HandleSensorStatusUseCase {
  final ICabinOperationService _service;

  HandleSensorStatusUseCase(this._service);

  Future<void> call({
    required DrawerPhysicalStatus status,
    required DrawerStage currentStage,
    required CabinAssignment assignment,
    required ManagementCard manager,
    required Function(DrawerStage stage, String message) onUpdate,
    bool openCubicLid = true,
  }) async {
    final isCubic = assignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;

    // SENARYO 1: Çekilme Bekleniyor (WaitingForPull)
    if (currentStage == DrawerStage.waitingForPull) {
      if (status == DrawerPhysicalStatus.fullyOpen) {
        if (isCubic && openCubicLid) {
          // KÜBİK: Çekmece çekildi, şimdi iç kapağı otomatik açalım
          await _handleCubicLidOpening(assignment, manager, onUpdate);
        } else {
          // STANDART/SERUM: Çekildi, doluma hazırız
          onUpdate(DrawerStage.readyForFilling, "Çekmece açık. Dolum yapabilirsiniz.");
        }
      }
    }

    // SENARYO 2: Kapanma Bekleniyor (WaitingForClose)
    if (currentStage == DrawerStage.waitingForClose) {
      if (status == DrawerPhysicalStatus.locked) {
        onUpdate(DrawerStage.completed, "İşlem başarıyla tamamlandı.");
      }
    }
  }

  // Kübik iç kapak açma alt süreci
  Future<void> _handleCubicLidOpening(
    CabinAssignment item,
    ManagementCard manager,
    Function(DrawerStage, String) onUpdate,
  ) async {
    onUpdate(DrawerStage.openingLid, "Çekmece algılandı. İlaç kapağı açılıyor...");

    try {
      // Notifier'daki adres hesaplama UseCase içine taşınmıştı, oradan alıyoruz
      final lidAddress = calculateAddressFromAssignment(item);

      await _service.openCubic(
        manager: manager,
        row: lidAddress.row,
        port: lidAddress.port,
        lidIndex: lidAddress.index,
      );

      onUpdate(DrawerStage.readyForFilling, "Kapak açıldı. Dolum yapabilirsiniz.");
    } catch (e) {
      onUpdate(DrawerStage.error, "Kapak açma hatası: $e");
    }
  }
}
