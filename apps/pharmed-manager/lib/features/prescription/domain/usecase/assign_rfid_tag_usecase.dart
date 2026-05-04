// [SWREQ-RFID-005] [IEC 62304 §5.5]
// Reçete kalemine RFID etiketi atama use case'i.
//
// Akış:
//   1. Bağlı değilse default ayarlarla connect()
//   2. IRfidService.scan() → tag listesi
//   3. Liste boşsa → NotFoundException
//   4. En yüksek RSSI'lı tag seçilir (okuyucuya en yakın fiziksel etiket)
//   5. IPrescriptionRepository.assignRfidTag(itemId, epc) → API isteği
//   6. Başarılıysa atanan EPC string döner
//
// Not: Host/port ilerleyen aşamada ayarlar ekranından okunacak.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class AssignRfidTagUseCase {
  const AssignRfidTagUseCase(this._rfidService, this._prescriptionRepository);

  final IRfidService _rfidService;
  final IPrescriptionRepository _prescriptionRepository;

  // TODO: Ayarlar ekranı implemente edilene kadar default değerler
  static const _defaultHost = '192.168.1.190';
  static const _defaultPort = 6000;

  Future<Result<String>> call(int prescriptionItemId) async {
    // 1. Her scan öncesi reconnect — Socket stream tek kullanımlık olduğu için
    //    önceki bağlantı kapatılıp yeni bir socket açılır.
    await _rfidService.disconnect();
    final connectResult = await _rfidService.connect(_defaultHost, _defaultPort);
    final connectError = connectResult.when(ok: (_) => null, error: (e) => e);
    if (connectError != null) return Result.error(connectError);

    // 2. Scan
    final scanResult = await _rfidService.scan();
    final scanError = scanResult.when(ok: (_) => null, error: (e) => e);
    if (scanError != null) return Result.error(scanError);

    final tags = scanResult.when(ok: (t) => t, error: (_) => <RfidTag>[]);

    // 3. Tag bulunamadı
    if (tags.isEmpty) {
      return Result.error(
        NotFoundException(
          message: 'Okuyucu alanında RFID etiketi bulunamadı.',
          id: prescriptionItemId,
          resourceType: 'RfidTag',
        ),
      );
    }

    // 4. En yüksek RSSI — okuyucuya en yakın etiket
    final bestTag = tags.reduce((a, b) => a.rssi > b.rssi ? a : b);

    // 5. API — etiketi kaleme bağla
    return _prescriptionRepository.assignRfidTag(prescriptionItemId: prescriptionItemId, epc: bestTag.epc);
  }
}
