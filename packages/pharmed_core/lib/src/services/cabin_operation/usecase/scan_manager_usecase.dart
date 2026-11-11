import 'package:pharmed_core/pharmed_core.dart';

class ScanManagerUseCase {
  const ScanManagerUseCase(this._cabinOps);

  final ICabinOperationService _cabinOps;

  /// Seri bağlantıyı hazırlar ve komutların gideceği yönetim kartını döner.
  ///
  /// [cabinNo]: İşlem yapılacak kabinin yönetim kartı adresi ([Cabin.no], 'a'-'p').
  /// Aynı RS485 hattında birden fazla kabin olabileceğinden verilmelidir; verilirse
  /// komutlar bu adrese gider. Verilmezse (tek kabinli eski akışlar) bağlantı
  /// sırasında bulunan kart döner.
  Future<ManagementCard> call({String? targetPort, String? cabinNo}) async {
    try {
      final manager = await _cabinOps.getOrScanManager(targetPort: targetPort);
      if (manager == null) {
        throw const CabinConnectionException(CabinConnectionFailure.managerNotFound);
      }
      final target = ManagementCard.indexFromAddressChar(cabinNo);
      if (target == null || target == manager.addressIndex) return manager;
      return ManagementCard(addressIndex: target);
    } catch (e) {
      if (e is CabinConnectionException) rethrow;
      throw CabinConnectionException(CabinConnectionFailure.managerConnectFailed, detail: e.toString());
    }
  }
}
