// pharmed_core/lib/src/prescription/usecase/assign_rfid_tag_use_case.dart
//
// [SWREQ-RFID-ASSIGN-001] [IEC 62304 §5.5]
// Bir reçete kalemine RFID etiketi atar.
//
// Akış:
//   1. RFID okuyucuya bağlan (gerekirse)
//   2. Inventory stream'i başlat (Real-time mode)
//   3. Hibrit pencere ile tag topla:
//        - İlk tag için max 3sn bekle (timeout)
//        - İlk tag geldikten sonra 500ms daha topla (komşu tag'lerin RSSI'ı için)
//   4. Inventory'i durdur (Answer Mode'a geri dön)
//   5. En yüksek RSSI'a sahip tag'i (= en yakın etiketi) seç
//   6. Backend'e gönder, prescription item ile eşle
//
// Sınıf: Class B

import 'dart:async';

import 'package:pharmed_manager/core/core.dart';

class AssignRfidTagUseCase {
  const AssignRfidTagUseCase(this._rfidService, this._prescriptionRepository);

  final IRfidService _rfidService;
  final IPrescriptionRepository _prescriptionRepository;

  // TODO: Ayarlar ekranı implemente edilene kadar default değerler
  static const _defaultHost = '192.168.1.190';
  static const _defaultPort = 6000;

  /// İlk tag için maksimum bekleme süresi.
  static const _firstTagTimeout = Duration(seconds: 10);

  /// İlk tag geldikten sonra ek toplama penceresi (komşu tag'lerin RSSI'ı için).
  static const _collectionWindow = Duration(milliseconds: 500);

  Future<Result<String>> call(int prescriptionItemId) async {
    // ── 1. Bağlantı (gerekirse) ───────────────────────────────────────────
    if (!_rfidService.isConnected) {
      final connectResult = await _rfidService.connect(_defaultHost, _defaultPort);
      final connectError = connectResult.when(ok: (_) => null, error: (e) => e);
      if (connectError != null) return Result.error(connectError);
    }

    // ── 2. Tag toplama (hibrit pencere) ───────────────────────────────────
    final tagsResult = await _collectTagsWithWindow();

    return tagsResult.when(
      ok: (tags) async {
        if (tags.isEmpty) {
          return Result<String>.error(
            NotFoundException(
              message: contextlessL10n().prescriptionCore_rfidTagNotFoundInReader,
              id: prescriptionItemId,
              resourceType: 'RfidTag',
            ),
          );
        }

        // ── 3. En yüksek RSSI — okuyucuya en yakın etiket ──────────────────
        // Aynı EPC birden fazla okunmuş olabilir; her EPC için max RSSI'ı al,
        // sonra en yüksek RSSI'lı EPC'yi seç.
        final bestRssiByEpc = <String, int>{};
        for (final tag in tags) {
          final current = bestRssiByEpc[tag.epc];
          if (current == null || tag.rssi > current) {
            bestRssiByEpc[tag.epc] = tag.rssi;
          }
        }

        final bestEpc = bestRssiByEpc.entries.reduce((a, b) => a.value > b.value ? a : b).key;

        MedLogger.info(
          unit: 'AssignRfidTagUseCase',
          swreq: 'SWREQ-RFID-ASSIGN-001',
          message: 'En güçlü RFID etiketi seçildi',
          context: {'epc': bestEpc, 'rssi': bestRssiByEpc[bestEpc], 'totalUniqueTags': bestRssiByEpc.length},
        );

        // ── 4. Backend'e ata ───────────────────────────────────────────────
        return _prescriptionRepository.assignRfidTag(prescriptionItemId: prescriptionItemId, epc: bestEpc);
      },
      error: (e) => Result<String>.error(e),
    );
  }

  /// Hibrit pencere mantığı:
  ///   - İlk tag gelene kadar max [_firstTagTimeout] bekle
  ///   - İlk tag geldikten sonra [_collectionWindow] boyunca daha topla
  ///   - Stream'i her durumda kapat (stopInventory)
  Future<Result<List<RfidTag>>> _collectTagsWithWindow() async {
    StreamSubscription<RfidTag>? sub;
    final tags = <RfidTag>[];
    final firstTagCompleter = Completer<void>();

    try {
      final stream = _rfidService.startInventory();

      sub = stream.listen(
        (tag) {
          tags.add(tag);
          if (!firstTagCompleter.isCompleted) {
            firstTagCompleter.complete();
          }
        },
        onError: (e) {
          if (!firstTagCompleter.isCompleted) {
            firstTagCompleter.completeError(e);
          }
        },
      );

      // İlk tag'i bekle (max 3sn)
      try {
        await firstTagCompleter.future.timeout(_firstTagTimeout);
      } on TimeoutException {
        // Tag yok — boş liste dön
        return const Result.ok([]);
      }

      // İlk tag geldi — 500ms daha topla
      await Future.delayed(_collectionWindow);

      return Result.ok(List.unmodifiable(tags));
    } catch (e) {
      MedLogger.error(
        unit: 'AssignRfidTagUseCase',
        swreq: 'SWREQ-RFID-ASSIGN-001',
        message: 'Tag toplama hatası',
        context: {'error': e.toString()},
      );
      return Result.error(
        ServiceException(message: contextlessL10n().prescriptionCore_rfidReadErrorWithDetail(e.toString()), statusCode: 500),
      );
    } finally {
      await sub?.cancel();
      await _rfidService.stopInventory();
    }
  }
}
