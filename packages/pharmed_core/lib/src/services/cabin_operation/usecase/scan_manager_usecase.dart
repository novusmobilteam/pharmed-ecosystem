import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class ScanManagerUseCase {
  ScanManagerUseCase(this._cabinOps, [this._cabinRepository]);

  final ICabinOperationService _cabinOps;
  final ICabinRepository? _cabinRepository;

  /// cabinId → yönetim kartı adresi (1-16). Kabin adresi yalnız kabin
  /// oluşturulurken atanır; uygulama ömrü boyunca tutmak güvenli.
  static final Map<int, int> _addressCache = {};

  /// Seri bağlantıyı hazırlar ve komutların gideceği yönetim kartını döner.
  ///
  /// Aynı RS485 hattında birden fazla kabin olabileceğinden hedef kabin
  /// verilmelidir:
  /// - [cabinNo]: kabinin yönetim kartı adresi ([Cabin.no], 'a'-'p').
  /// - [cabinId]: adres bilinmiyorsa (ör. serum avadanlık ataması iç içe kabin
  ///   taşımaz) kabin servisten çekilip adres çözülür.
  ///
  /// Adres çözülemezse hata loglanır ve bağlantıda bulunan kart döner
  /// (tek kabinli kurulumlar için) — çoklu kabinde bu yanlış kabin demektir.
  Future<ManagementCard> call({String? targetPort, String? cabinNo, int? cabinId}) async {
    final ManagementCard manager;
    try {
      final found = await _cabinOps.getOrScanManager(targetPort: targetPort);
      if (found == null) {
        throw const CabinConnectionException(CabinConnectionFailure.managerNotFound);
      }
      manager = found;
    } catch (e) {
      if (e is CabinConnectionException) rethrow;
      throw CabinConnectionException(CabinConnectionFailure.managerConnectFailed, detail: e.toString());
    }

    final target = ManagementCard.indexFromAddressChar(cabinNo) ?? await _resolveAddress(cabinId);
    if (target == null) {
      if (cabinNo != null || cabinId != null) {
        MedLogger.error(
          unit: 'CabinOps',
          swreq: 'SWREQ-CABIN-OP-003',
          message: 'Kabin yönetim kartı adresi çözülemedi, bağlantıdaki kart kullanılıyor',
          context: {'cabinNo': cabinNo, 'cabinId': cabinId, 'kullanilanAdres': manager.addressChar},
        );
      }
      return manager;
    }
    if (target == manager.addressIndex) return manager;
    return ManagementCard(addressIndex: target);
  }

  Future<int?> _resolveAddress(int? cabinId) async {
    if (cabinId == null) return null;
    final cached = _addressCache[cabinId];
    if (cached != null) return cached;

    final repo = _cabinRepository;
    if (repo == null) return null;
    final result = await repo.getCabin(cabinId);
    final index = ManagementCard.indexFromAddressChar(result.when(ok: (c) => c?.no, error: (_) => null));
    if (index != null) _addressCache[cabinId] = index;
    return index;
  }
}
