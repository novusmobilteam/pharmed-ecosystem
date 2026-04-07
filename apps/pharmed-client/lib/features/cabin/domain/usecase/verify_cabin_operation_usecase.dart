// pharmed-client/features/cabin/domain/use_case/verify_cabinet_operation_use_case.dart

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/model/rfid_tag.dart';
import '../../../../core/hardware/service/rfid/i_rfid_service.dart';

/// Kabin operasyonu öncesi ve sonrası RFID snapshot'larını karşılaştırarak
/// kabinden çıkan (removed) ve kabine giren (added) tag'leri tespit eder.
///
/// Akış:
///   1. [takeSnapshot] → T1 (çekmece açılmadan önce)
///   2. Çekmece açılır, kullanıcı işlem yapar, çekmece kapanır
///   3. [takeSnapshot] → T2 (çekmece kapandıktan sonra)
///   4. [computeDelta(T1, T2)] → [RfidDelta]
///
/// Orchestration (sıralama ve çağrı zamanlaması) Notifier sorumluluğundadır.
/// Bu UseCase yalnızca snapshot alma ve delta hesaplama yapar.
class VerifyCabinetOperationUseCase {
  const VerifyCabinetOperationUseCase(this._rfidService);

  final IRfidService _rfidService;

  /// Mevcut kabindeki tag'lerin anlık görüntüsünü alır.
  Future<Result<List<RfidTag>>> takeSnapshot() async {
    MedLogger.info(unit: 'VerifyCabinetOperationUseCase', swreq: 'SWREQ-RFID-010', message: 'Snapshot alınıyor');

    final result = await _rfidService.scan();

    result.when(
      ok: (tags) => MedLogger.info(
        unit: 'VerifyCabinetOperationUseCase',
        swreq: 'SWREQ-RFID-010',
        message: 'Snapshot alındı',
        context: {'tagCount': tags.length},
      ),
      error: (e) => MedLogger.error(
        unit: 'VerifyCabinetOperationUseCase',
        swreq: 'SWREQ-RFID-010',
        message: 'Snapshot hatası',
        context: {'error': e.message},
      ),
    );

    return result;
  }

  /// T1 ve T2 snapshot'larını karşılaştırarak delta hesaplar.
  ///
  /// [before] → T1: çekmece açılmadan önceki tag listesi
  /// [after]  → T2: çekmece kapandıktan sonraki tag listesi
  ///
  /// [RfidDelta.removed] → T1'de var T2'de yok → kabinden çıkan ilaç
  /// [RfidDelta.added]   → T2'de var T1'de yok → kabine giren ilaç
  Result<RfidDelta> computeDelta(List<RfidTag> before, List<RfidTag> after) {
    final beforeEpcs = before.map((t) => t.epc).toSet();
    final afterEpcs = after.map((t) => t.epc).toSet();

    final removed = before.where((t) => !afterEpcs.contains(t.epc)).toList();
    final added = after.where((t) => !beforeEpcs.contains(t.epc)).toList();

    final delta = RfidDelta(added: added, removed: removed);

    MedLogger.info(
      unit: 'VerifyCabinetOperationUseCase',
      swreq: 'SWREQ-RFID-011',
      message: 'Delta hesaplandı',
      context: {'before': before.length, 'after': after.length, 'added': added.length, 'removed': removed.length},
    );

    return Result.ok(delta);
  }
}

/// Kabin operasyonu sonucu RFID delta verisi.
class RfidDelta {
  /// T2'de var T1'de yok → kabine giren tag (iade, dolum vb.)
  final List<RfidTag> added;

  /// T1'de var T2'de yok → kabinden çıkan tag (alım, taburcu vb.)
  final List<RfidTag> removed;

  const RfidDelta({required this.added, required this.removed});

  bool get isEmpty => added.isEmpty && removed.isEmpty;

  @override
  String toString() => 'RfidDelta(added: ${added.length}, removed: ${removed.length})';
}
